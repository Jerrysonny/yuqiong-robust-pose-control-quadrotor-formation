module FormationMetricsV8

using Statistics
using TOML

include(joinpath(@__DIR__, "CanonicalMetricsV8.jl"))
using .CanonicalMetricsV8

export evaluate_formation_file, write_formation_outputs

function require_so3_v8(context::EvidenceContext)
    validate_context(context)
    context.candidate_id == SO3_V8_CANDIDATE ||
        error("SO3 v8 formation metrics require candidate $SO3_V8_CANDIDATE")
    context.controller_id == SO3_V8_CONTROLLER ||
        error("SO3 v8 formation metrics require controller $SO3_V8_CONTROLLER")
    context.evidence_track == SO3_V8_TRACK ||
        error("SO3 v8 formation metrics cannot consume V2B evidence")
    return true
end

required(table, name) = find_series(table, [name])
matrix3(table, names) = hcat([required(table, name) for name in names]...)

function optional_diagnostics(table)
    columns = [find_series(table, ["supervisorDiagnostics[$index]"];
        required=false) for index in 1:8]
    count_available = count(column -> column !== nothing, columns)
    count_available in (0, 8) ||
        error("partial supervisor diagnostics: expected zero or eight columns")
    return count_available == 0 ? nothing : hcat(columns...)
end

function optional_rotation_matrices(table)
    rows = table.nrows
    rotations = Array{Float64}(undef, rows, 3, 9)
    vehicle_available = Bool[]
    for vehicle in 1:3
        columns = [find_series(table, [
            "quad$vehicle.body.frame_b.R.T[$row,$column]",
            "quad$(vehicle)_rotation_r$(row)$(column)"];
            required=false) for row in 1:3 for column in 1:3]
        count_available = count(value -> value !== nothing, columns)
        count_available in (0, 9) || error(
            "partial rotation matrix for vehicle $vehicle: expected zero or nine columns")
        push!(vehicle_available, count_available == 9)
        count_available == 9 && (rotations[:, vehicle, :] = hcat(columns...))
    end
    all(vehicle_available) && return rotations
    !any(vehicle_available) && return nothing
    error("partial formation rotation evidence: expected matrices for all three vehicles")
end

function formation_rotation_quality(rotations)
    rotations === nothing && return nothing
    rows = size(rotations, 1)
    orthogonality = Array{Float64}(undef, rows, 3)
    determinants = similar(orthogonality)
    for vehicle in 1:3
        quality = CanonicalMetricsV8.CanonicalMetricsV7.rotation_quality(
            rotations[:, vehicle, :])
        orthogonality[:, vehicle] = quality.orthogonality
        determinants[:, vehicle] = quality.determinants
    end
    return (; orthogonality, determinants)
end

function extract_formation(table)
    # 同时保留名义队形、监督后指令和实际位置，避免混淆三类误差。
    time = required(table, "time")
    rows = table.nrows
    leader = matrix3(table, ["leaderReference[$axis]" for axis in 1:3])
    offsets = Array{Float64}(undef, rows, 3, 3)
    commanded = similar(offsets)
    actual = similar(offsets)
    attitude = similar(offsets)
    body_rate = similar(offsets)
    motor = Array{Float64}(undef, rows, 3, 4)
    for vehicle in 1:3
        offsets[:, vehicle, :] = matrix3(table,
            ["formationOffset[$(3 * (vehicle - 1) + axis)]" for axis in 1:3])
        commanded[:, vehicle, :] = matrix3(table,
            ["formationReference[$(9 * (vehicle - 1) + axis)]" for axis in 1:3])
        actual[:, vehicle, :] = matrix3(table,
            ["quad$vehicle.body.r_0[$axis]" for axis in 1:3])
        attitude[:, vehicle, :] = matrix3(table,
            ["sensors$vehicle.AngleMea[$axis]" for axis in 1:3])
        body_rate[:, vehicle, :] = matrix3(table,
            ["quad$vehicle.body.frame_b.R.w[$axis]" for axis in 1:3])
        motor[:, vehicle, :] = hcat(
            [required(table, "motorCommand$vehicle[$index]") for index in 1:4]...)
    end
    nominal = similar(actual)
    for vehicle in 1:3
        nominal[:, vehicle, :] = leader + offsets[:, vehicle, :]
    end
    nominal_error = sqrt.(dropdims(sum(abs2, actual - nominal; dims=3); dims=3))
    commanded_error = sqrt.(dropdims(sum(abs2, actual - commanded; dims=3); dims=3))
    correction = sqrt.(dropdims(sum(abs2, commanded - nominal; dims=3); dims=3))
    formation_error = Array{Float64}(undef, rows, 2)
    for follower in 2:3
        relative_actual = actual[:, follower, :] - actual[:, 1, :]
        relative_nominal = nominal[:, follower, :] - nominal[:, 1, :]
        formation_error[:, follower - 1] = sqrt.(dropdims(sum(abs2,
            relative_actual - relative_nominal; dims=2); dims=2))
    end
    pairwise = hcat(
        sqrt.(dropdims(sum(abs2, actual[:, 1, :] - actual[:, 2, :]; dims=2); dims=2)),
        sqrt.(dropdims(sum(abs2, actual[:, 1, :] - actual[:, 3, :]; dims=2); dims=2)),
        sqrt.(dropdims(sum(abs2, actual[:, 2, :] - actual[:, 3, :]; dims=2); dims=2)))
    rotations = optional_rotation_matrices(table)
    rotation_quality = formation_rotation_quality(rotations)
    tilt = rotations === nothing ? nothing : acos.(clamp.(rotations[:, :, 9], -1.0, 1.0))
    diagnostics = optional_diagnostics(table)
    return (; time, leader, offsets, nominal, commanded, actual, attitude, body_rate,
        motor, diagnostics, rotations, rotation_quality, nominal_error,
        commanded_error, correction, formation_error, pairwise, tilt)
end

function sustained_recovery(time, values, start_time, limit, hold_s)
    start_row = searchsortedfirst(time, start_time)
    start_row > length(time) && return nothing
    for row in start_row:length(time)
        last_row = searchsortedlast(time, time[row] + hold_s + 1e-12)
        last_row <= length(time) || continue
        all(values[row:last_row] .<= limit) && return time[row] - start_time
    end
    return nothing
end

function evaluate_formation_file(path; context::EvidenceContext,
    # 安全距离、编队误差和全局跟踪代价分别计算，不合并成单一分数。
        scene=infer_scene(path), config_path=nothing, expected_stop=nothing,
        transition_start_s=30.0, transition_hold_s=1.0)
    require_so3_v8(context)
    table = read_numeric_csv(path)
    data = extract_formation(table)
    config = config_path === nothing ? Dict{String,Any}() : TOML.parsefile(config_path)
    stop_time = expected_stop === nothing ? expected_stop_time(config, scene) :
        Float64(expected_stop)
    safe_distance = Float64(config_value(config,
        ["formation_gates", "minimum_distance_m"], 0.60))
    formation_limit = Float64(config_value(config,
        ["formation_gates", "formation_rmse_m"], 0.15))
    tilt_limit = Float64(config_value(config,
        ["global_gates", "max_yawless_tilt_rad"],
        config_value(config, ["global_gates", "max_tilt_rad"], 1.20)))
    rate_limit = Float64(config_value(config,
        ["global_gates", "max_body_rate_radps"], 20.0))
    q_max = Float64(config_value(config, ["global_gates", "q_max"], 3600.0))
    rotation_tolerance = Float64(config_value(config,
        ["global_gates", "rotation_orthogonality_tolerance"], 1e-6))

    finite = all(name -> all(isfinite, table.columns[name]), table.names)
    minimum_distance_by_pair = vec(minimum(data.pairwise; dims=1))
    minimum_distance_series = vec(minimum(data.pairwise; dims=2))
    minimum_distance = minimum(minimum_distance_series)
    violation_indicator = Float64.(minimum_distance_series .< safe_distance)
    violation_duration = trapezoid(violation_indicator, data.time)
    formation_max_series = vec(maximum(data.formation_error; dims=2))
    transition_recovery = scene == "Scene07B" ? sustained_recovery(data.time,
        formation_max_series, transition_start_s, formation_limit, transition_hold_s) : nothing
    active_after_takeoff = data.time .>= 5.0
    formation_after_takeoff = any(active_after_takeoff) ?
        sqrt(mean(abs2, data.formation_error[active_after_takeoff, :])) : nothing
    smoothness = motor_smoothness(reshape(data.motor, length(data.time), 12), data.time)
    correction_energy = trapezoid(
        vec(sum(abs2, data.commanded - data.nominal; dims=(2, 3))), data.time)
    diagnostics_available = data.diagnostics !== nothing
    rotation_available = data.rotations !== nothing
    max_rotation_orthogonality = rotation_available ?
        maximum(data.rotation_quality.orthogonality) : nothing
    min_rotation_determinant = rotation_available ?
        minimum(data.rotation_quality.determinants) : nothing
    max_rotation_determinant_error = rotation_available ?
        maximum(abs.(data.rotation_quality.determinants .- 1.0)) : nothing
    max_yawless_tilt = rotation_available ? maximum(data.tilt) : nothing
    projection_energy = diagnostics_available ?
        trapezoid(abs2.(data.diagnostics[:, 5]), data.time) : nothing

    metrics = merge(Dict{String,Any}(
        "scene" => scene,
        "source_file" => abspath(path),
        "samples" => table.nrows,
        "stop_time_s" => data.time[end],
        "vehicle_count" => 3,
        "tracking_nominal_rmse_m" => sqrt(mean(abs2, data.nominal_error)),
        "tracking_commanded_rmse_m" => sqrt(mean(abs2, data.commanded_error)),
        "formation_rmse_m" => sqrt(mean(abs2, data.formation_error)),
        "formation_peak_m" => maximum(data.formation_error),
        "formation_rmse_after_takeoff_m" => formation_after_takeoff,
        "minimum_pairwise_distance_m" => minimum_distance,
        "minimum_pairwise_margin_m" => minimum_distance - safe_distance,
        "minimum_distance_12_m" => minimum_distance_by_pair[1],
        "minimum_distance_13_m" => minimum_distance_by_pair[2],
        "minimum_distance_23_m" => minimum_distance_by_pair[3],
        "safety_violation_duration_s" => violation_duration,
        "safety_violation_fraction" => mean(minimum_distance_series .< safe_distance),
        "transition_recovery_time_s" => transition_recovery,
        "transition_recovery_status" => scene != "Scene07B" ? "not_applicable" :
            transition_recovery === nothing ? "not_recovered" : "recovered",
        "reference_correction_rmse_m" => sqrt(mean(abs2, data.correction)),
        "reference_correction_peak_m" => maximum(data.correction),
        "cbf_reference_correction_energy_m2_s" => correction_energy,
        "cbf_projection_correction_energy_m4_s3" => projection_energy,
        "minimum_final_hocbf_residual" => diagnostics_available ?
            minimum(data.diagnostics[:, 2]) : nothing,
        "cbf_active_fraction" => diagnostics_available ?
            mean(data.diagnostics[:, 4] .> 0.5) : nothing,
        "maximum_projection_correction_mps2" => diagnostics_available ?
            maximum(data.diagnostics[:, 5]) : nothing,
        "infeasible_max" => diagnostics_available ? maximum(data.diagnostics[:, 6]) : nothing,
        "hold_max" => diagnostics_available ? maximum(data.diagnostics[:, 7]) : nothing,
        "max_yawless_tilt_rad" => max_yawless_tilt,
        "yawless_tilt_evidence_method" => rotation_available ?
            "rotation_matrix_r33" : "not_evaluable_rotation_matrix_missing",
        "max_rotation_orthogonality_error" => max_rotation_orthogonality,
        "min_rotation_determinant" => min_rotation_determinant,
        "max_rotation_determinant_error" => max_rotation_determinant_error,
        "max_abs_body_rate_radps" => maximum(abs, data.body_rate),
        "max_motor_command_q" => maximum(abs2, data.motor),
        "motor_total_variation" => smoothness.total_variation,
        "motor_rms_slew_rate" => smoothness.rms_slew_rate,
        "evidence_has_supervisor_diagnostics" => diagnostics_available,
        "evidence_supervisor_diagnostics_dimension" => diagnostics_available ? 8 : 0,
        "evidence_has_rotation_matrix" => rotation_available,
        "evidence_rotation_matrix_vehicle_count" => rotation_available ? 3 : 0,
        "evidence_has_motor_applied" => false),
        CanonicalMetricsV8.provenance(context, "formation"))

    gates = Dict{String,Any}(
        "scene" => scene,
        "time_contract" => finite && abs(data.time[1]) <= 1e-12 &&
            abs(data.time[end] - stop_time) <= 1e-8 && all(diff(data.time) .> 0.0),
        "minimum_distance_ge_limit" => minimum_distance >= safe_distance,
        "safety_violation_duration_zero" => violation_duration <= 1e-12,
        "required_rotation_matrix_evidence" => rotation_available,
        "rotation_orthogonality_le_tolerance" => rotation_available ?
            max_rotation_orthogonality <= rotation_tolerance : nothing,
        "rotation_determinant_positive" => rotation_available ?
            min_rotation_determinant > 0.0 : nothing,
        "rotation_determinant_error_le_tolerance" => rotation_available ?
            max_rotation_determinant_error <= rotation_tolerance : nothing,
        "yawless_tilt_le_limit" => rotation_available ?
            max_yawless_tilt <= tilt_limit : nothing,
        "body_rate_le_limit" => maximum(abs, data.body_rate) <= rate_limit,
        "motor_command_q_le_limit" => maximum(abs2, data.motor) <= q_max + 1e-8,
        "evidence_track_binding" => true,
        "evidence_has_supervisor_diagnostics" => diagnostics_available)
    if scene == "Scene07B"
        gates["formation_rmse_after_takeoff_lt_limit"] = formation_after_takeoff === nothing ?
            nothing : formation_after_takeoff < formation_limit
        gates["transition_recovery_le_5_s"] = transition_recovery === nothing ?
            nothing : transition_recovery <= 5.0
    elseif scene == "Scene07C"
        gates["required_supervisor_diagnostics"] = diagnostics_available
        gates["final_hocbf_residual_ge_minus_1e_6"] = diagnostics_available ?
            minimum(data.diagnostics[:, 2]) >= -1e-6 : nothing
        gates["cbf_activated"] = diagnostics_available ?
            mean(data.diagnostics[:, 4] .> 0.5) > 0.0 : nothing
        gates["no_infeasible_or_hold"] = diagnostics_available ?
            maximum(data.diagnostics[:, 6]) < 0.5 &&
            maximum(data.diagnostics[:, 7]) < 0.5 : nothing
    end
    CanonicalMetricsV8.recompute_all_pass!(gates)
    return (; table, data, metrics, gates)
end

function write_formation_timeseries(path, data)
    diagnostics_active = data.diagnostics === nothing ? nothing : data.diagnostics[:, 4]
    names = ["time", "formation_error_max_m", "minimum_pairwise_distance_m",
        "reference_correction_max_m", "cbf_active_count"]
    columns = Any[data.time, vec(maximum(data.formation_error; dims=2)),
        vec(minimum(data.pairwise; dims=2)), vec(maximum(data.correction; dims=2)),
        diagnostics_active]
    mkpath(dirname(path))
    open(path, "w") do stream
        println(stream, join(names, ','))
        for row in eachindex(data.time)
            values = [column === nothing ? nothing : column[row] for column in columns]
            println(stream, join(csv_escape.(values), ','))
        end
    end
end

function write_formation_outputs(result, output_root, stem)
    # 指标摘要和时序数据使用同一评价结果写出。
    paths = Dict(
        "timeseries_csv" => joinpath(output_root, "canonical", stem * "_formation_v8.csv"),
        "metrics_csv" => joinpath(output_root, "metrics", stem * "_formation_metrics_v8.csv"),
        "metrics_json" => joinpath(output_root, "metrics", stem * "_formation_metrics_v8.json"),
        "hard_gates_csv" => joinpath(output_root, "hard_gates", stem * "_formation_gates_v8.csv"),
        "hard_gates_json" => joinpath(output_root, "hard_gates", stem * "_formation_gates_v8.json"))
    write_formation_timeseries(paths["timeseries_csv"], result.data)
    write_row_csv(paths["metrics_csv"], result.metrics)
    write_json(paths["metrics_json"], result.metrics)
    write_row_csv(paths["hard_gates_csv"], result.gates)
    write_json(paths["hard_gates_json"], result.gates)
    return paths
end

end
