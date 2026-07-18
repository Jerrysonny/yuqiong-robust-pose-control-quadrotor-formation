module CampaignMetrics

using Dates
using SHA
using Statistics
using TOML

export evaluate_campaign, evaluate_formation_file, evaluate_single_file,
    expected_stop_time, frozen_source_manifest, load_campaign_config,
    paired_comparison, suite_case_ids, write_campaign_outputs

const WORKSPACE = dirname(dirname(@__DIR__))
const CORE_ROOT = WORKSPACE
isfile(joinpath(WORKSPACE, "config", "campaign.toml")) ||
    error("campaign workspace resolution failed: $WORKSPACE")
isdir(CORE_ROOT) || error("campaign core-root resolution failed: $CORE_ROOT")

const EXPECTED_FROZEN_SHA256 = Dict(
    "CanonicalMetricsV7.jl" =>
        "94f74c8952e2748c793ddd8d3452d87d45ccb6c397a2d499cfa2c7c3c0b19549",
    "TransientMetricsV7.jl" =>
        "983c4012c5931f1acb363e913a0ebe8a390905024b9f68c14a9d2f2232c6bab9",
    "FormationMetricsV8.jl" =>
        "d98576be6bb34e18e3f9978f2e797be65e080fea41477fb355131cbf43ff5e61",
    "CanonicalMetricsV8.jl" =>
        "e72416bc439220f4bb5c57f0c05e9fa714ebc70ea1d879545313008a9b7d1bdc",
    "V9DevelopmentMetrics.jl" =>
        "ed4aa40bc292e7bfef6a860a1289fba0989ddf3066b70e22389c03f8285e650f",
)
const EXCLUDED_SOURCE_SEGMENTS = (
    "99_backup", "99_rollback", "quarantine", "reproduction_probe")
const CAMPAIGN_SUITES = (
    "standard_steps", "main_single", "parameter", "wind", "sensor", "formation")
const PROVENANCE_KEYS = Set([
    "candidate_id", "controller_id", "evidence_track", "experiment_id",
    "run_id", "evaluation_kind", "evidence_track_validated", "schema_version",
])

file_sha256(path) = lowercase(bytes2hex(sha256(read(path))))

function excluded_source_path(path)
    lowered = lowercase(replace(normpath(path), '\\' => '/'))
    return any(segment -> occursin(lowercase(segment), lowered),
        EXCLUDED_SOURCE_SEGMENTS)
end

function find_frozen_source(root, filename, expected_sha256)
    # 仅加载哈希匹配且不位于备份、隔离目录中的指标源码。
    matches = String[]
    for (directory, subdirectories, files) in walkdir(root)
        filter!(name -> !excluded_source_path(joinpath(directory, name)), subdirectories)
        filename in files || continue
        path = joinpath(directory, filename)
        excluded_source_path(path) && continue
        file_sha256(path) == expected_sha256 && push!(matches, abspath(path))
    end
    isempty(matches) && error(
        "missing frozen source $filename with SHA-256 $expected_sha256 under $root")
    sort!(matches)
    return first(matches)
end

const CANONICAL_V7_PATH = find_frozen_source(CORE_ROOT, "CanonicalMetricsV7.jl",
    EXPECTED_FROZEN_SHA256["CanonicalMetricsV7.jl"])
const DELIVERY_METRICS_ROOT = dirname(CANONICAL_V7_PATH)

function require_delivery_source(filename)
    path = joinpath(DELIVERY_METRICS_ROOT, filename)
    isfile(path) || error("missing frozen delivery metric: $path")
    actual = file_sha256(path)
    expected = EXPECTED_FROZEN_SHA256[filename]
    actual == expected || error("frozen hash mismatch for $path: $actual != $expected")
    return path
end

const TRANSIENT_V7_PATH = require_delivery_source("TransientMetricsV7.jl")
const FORMATION_V8_PATH = require_delivery_source("FormationMetricsV8.jl")
const CANONICAL_V8_PATH = require_delivery_source("CanonicalMetricsV8.jl")
const V9_DEVELOPMENT_PATH = find_frozen_source(CORE_ROOT,
    "V9DevelopmentMetrics.jl", EXPECTED_FROZEN_SHA256["V9DevelopmentMetrics.jl"])

include(CANONICAL_V7_PATH)
include(TRANSIENT_V7_PATH)
include(FORMATION_V8_PATH)
include(V9_DEVELOPMENT_PATH)

const C7 = CanonicalMetricsV7
const T7 = TransientMetricsV7
const F8 = FormationMetricsV8
const V9 = V9DevelopmentMetrics

function frozen_source_manifest()
    return Dict{String,Any}(
        "CanonicalMetricsV7" => Dict("path" => CANONICAL_V7_PATH,
            "sha256" => file_sha256(CANONICAL_V7_PATH)),
        "TransientMetricsV7" => Dict("path" => TRANSIENT_V7_PATH,
            "sha256" => file_sha256(TRANSIENT_V7_PATH)),
        "FormationMetricsV8" => Dict("path" => FORMATION_V8_PATH,
            "sha256" => file_sha256(FORMATION_V8_PATH)),
        "CanonicalMetricsV8_dependency" => Dict("path" => CANONICAL_V8_PATH,
            "sha256" => file_sha256(CANONICAL_V8_PATH)),
        "V9DevelopmentMetrics" => Dict("path" => V9_DEVELOPMENT_PATH,
            "sha256" => file_sha256(V9_DEVELOPMENT_PATH)),
    )
end

default_config_path() = joinpath(WORKSPACE, "config", "campaign.toml")

function load_campaign_config(path=default_config_path())
    isfile(path) || error("missing campaign config: $path")
    config = TOML.parsefile(path)
    get(config, "campaign", "") == "v8_ra_gca_cghte_project_regression" ||
        error("unexpected campaign contract in $path")
    return config
end

section(config, name) = get(config, name, Dict{String,Any}())
number(config, group, key, default) =
    Float64(get(section(config, group), key, default))
boolean(config, group, key, default) = Bool(get(section(config, group), key, default))

function suite_case_ids(config)
    suite = section(config, "suite")
    return vcat([String.(get(suite, name, String[])) for name in CAMPAIGN_SUITES]...)
end

function case_suite(config, case_id)
    suite = section(config, "suite")
    for name in CAMPAIGN_SUITES
        case_id in String.(get(suite, name, String[])) && return name
    end
    error("case is not registered in campaign suite: $case_id")
end

function expected_stop_time(case_id)
    # 各场景停止时间与正式仿真配置保持一致。
    case_id == "Scene04" && return 30.0
    startswith(case_id, "Scene01S_") && return 30.0
    case_id == "Scene06b" && return 30.0
    case_id == "Scene03" && return 120.0
    startswith(case_id, "Scene08_") && return 40.0
    startswith(case_id, "Scene10_") && return 40.0
    case_id == "Scene07B" && return 60.0
    startswith(case_id, "Scene07C") && return 40.0
    return 50.0
end

function validate_hte_version(expected_hte_version)
    expected_hte_version === nothing && return nothing
    version = Int(expected_hte_version)
    version in (901, 914) || error("expected HTE version must be 901 or 914")
    return version
end

optional_series(table, candidates) = C7.find_series(table, candidates; required=false)
controller_diagnostic(table, index) = optional_series(table,
    ["controllerDiagnostics[$index]"])
scenario_diagnostic(table, index) = optional_series(table,
    ["scenarioDiagnostics[$index]"])

function steady_tracking_metrics(data; steady_fraction=0.20)
    # 稳态指标使用末20%样本，并分别计算偏差向量和误差范数。
    count = length(data.time)
    first_steady = max(1, floor(Int, (1.0 - steady_fraction) * count) + 1)
    signed_error = data.reference[first_steady:end, :] - data.position[first_steady:end, :]
    signed_mean = vec(mean(signed_error; dims=1))
    error_norm = vec(sqrt.(sum(abs2, signed_error; dims=2)))
    return Dict{String,Any}(
        "steady_abs_error_m" => sqrt(sum(abs2, signed_mean)),
        "steady_rmse_m" => sqrt(mean(abs2, error_norm)),
    )
end

function inferred_target_scale(table)
    lift = scenario_diagnostic(table, 1)
    mass = scenario_diagnostic(table, 2)
    if lift === nothing || mass === nothing || isempty(lift) || isempty(mass)
        return nothing
    end
    start = max(1, length(lift) - 99)
    lift_terminal = mean(@view lift[start:end])
    mass_terminal = mean(@view mass[start:end])
    isfinite(lift_terminal) && lift_terminal > 0.0 && isfinite(mass_terminal) ||
        return nothing
    return mass_terminal / lift_terminal
end

diagnostic_index(config, key, fallback) =
    Int(get(section(config, "hte_diagnostics"), key, fallback))

function hte_diagnostic_metrics(table, config; target_scale=nothing)
    # 诊断11至16统一解析估计尺度、门控、创新量、分配上界和版本码。
    scale_hat = controller_diagnostic(table,
        diagnostic_index(config, "scale_estimate_index", 11))
    scale_apply = controller_diagnostic(table,
        diagnostic_index(config, "scale_applied_index", 12))
    fusion_valid = controller_diagnostic(table,
        diagnostic_index(config, "fusion_valid_index", 13))
    innovation = controller_diagnostic(table,
        diagnostic_index(config, "normalized_innovation_index", 14))
    q_limit = controller_diagnostic(table,
        diagnostic_index(config, "allocator_qmax_index", 15))
    version = controller_diagnostic(table,
        diagnostic_index(config, "version_index", 16))
    metrics = Dict{String,Any}(
        "hte_diagnostics_complete" => all(value -> value !== nothing,
            (scale_hat, scale_apply, fusion_valid, innovation, q_limit, version)),
        "expected_target_scale" => target_scale,
        "version_min" => version === nothing ? nothing : minimum(version),
        "version_max" => version === nothing ? nothing : maximum(version),
        "allocator_q_limit_min" => q_limit === nothing ? nothing : minimum(q_limit),
        "allocator_q_limit_max" => q_limit === nothing ? nothing : maximum(q_limit),
    )
    if scale_hat !== nothing
        metrics["scale_hat_min"] = minimum(scale_hat)
        metrics["scale_hat_max"] = maximum(scale_hat)
    end
    if scale_apply !== nothing
        terminal_start = max(1, length(scale_apply) - 99)
        terminal = mean(@view scale_apply[terminal_start:end])
        metrics["scale_apply_min"] = minimum(scale_apply)
        metrics["scale_apply_max"] = maximum(scale_apply)
        metrics["scale_apply_max_deviation_from_one"] =
            maximum(abs.(scale_apply .- 1.0))
        metrics["scale_apply_terminal"] = terminal
        metrics["scale_apply_terminal_relative_error"] = target_scale === nothing ?
            nothing : abs(terminal - target_scale) / abs(target_scale)
    end
    fusion_valid === nothing || (metrics["fusion_valid_fraction"] =
        count(value -> value >= 0.5, fusion_valid) / length(fusion_valid))
    innovation === nothing || (metrics["normalized_innovation_abs_max"] =
        maximum(abs, innovation))
    return metrics
end

function longest_continuous_duration(time, active)
    # 持续时间按真实时间戳计算，避免依赖固定采样点数量。
    length(time) == length(active) || error("time and activity length mismatch")
    start_index = nothing
    longest = 0.0
    for index in eachindex(active)
        if active[index]
            start_index === nothing && (start_index = index)
        elseif start_index !== nothing
            longest = max(longest, time[index - 1] - time[start_index])
            start_index = nothing
        end
    end
    start_index === nothing ||
        (longest = max(longest, last(time) - time[start_index]))
    return longest
end

function scale_transparency_metrics(time, scale_series; deviation_threshold=0.04)
    isempty(scale_series) && return Dict{String,Any}(
        "scale_transparency_evidence" => false)
    terminal_deviations = Float64[]
    false_activation_durations = Float64[]
    for scale in scale_series
        length(scale) == length(time) || error("scale diagnostic length mismatch")
        terminal_start = max(1, length(scale) - 99)
        push!(terminal_deviations, abs(mean(@view scale[terminal_start:end]) - 1.0))
        push!(false_activation_durations, longest_continuous_duration(
            time, abs.(scale .- 1.0) .> deviation_threshold))
    end
    return Dict{String,Any}(
        "scale_transparency_evidence" => true,
        "terminal_scale_deviation_from_one_max" => maximum(terminal_deviations),
        "false_activation_continuous_duration_max_s" =>
            maximum(false_activation_durations),
    )
end

function complete_v9_evidence(table)
    required = vcat(
        ["controllerDiagnostics[$index]" for index in 11:16],
        ["speedSensor[$index].w" for index in 1:4],
        ["quadChassisTest17_1.body.frame_b.R.T[$row,$column]"
            for row in 1:3 for column in 1:3],
    )
    return all(name -> haskey(table.columns, name), required)
end

function time_contract_gates(table, time, expected_stop, config)
    sample_time = Float64(get(config, "sample_time_s", 0.01))
    expected_rows = round(Int, expected_stop / sample_time) + 1
    increments = diff(time)
    return Dict{String,Bool}(
        "required_finite_numeric_evidence" =>
            all(column -> all(isfinite, column), values(table.columns)),
        "required_start_time_zero" => abs(first(time)) <= 1.0e-12,
        "required_stop_time" => abs(last(time) - expected_stop) <= 1.0e-8,
        "required_strictly_increasing_time" => all(increments .> 0.0),
        "required_sample_count" => length(time) == expected_rows,
        "required_sample_interval" => all(abs.(increments .- sample_time) .<= 1.0e-8),
    )
end

function single_physical_gates(base, config, expected_stop, expected_hte_version)
    # 物理门逐项保留，禁止用综合平均值掩盖单项失败。
    table, data, metrics = base.table, base.data, base.metrics
    gates = time_contract_gates(table, data.time, expected_stop, config)
    physical = section(config, "physical_gates")
    orthogonality_limit = Float64(get(physical,
        "rotation_orthogonality_tolerance", 1.0e-6))
    determinant_limit = Float64(get(physical,
        "rotation_determinant_tolerance", 1.0e-6))
    tilt_limit = Float64(get(physical, "max_yawless_tilt_rad", 1.20))
    rate_limit = Float64(get(physical, "max_body_rate_radps", 20.0))
    motor_tolerance = Float64(get(physical, "motor_limit_tolerance", 1.0e-8))
    rotation_available = data.rotation !== nothing
    q_limit = controller_diagnostic(table,
        diagnostic_index(config, "allocator_qmax_index", 15))
    q_limit === nothing && (q_limit = scenario_diagnostic(table, 10))
    q_has_positive_evidence = q_limit !== nothing &&
        any(value -> isfinite(value) && value > 0.0, q_limit)
    if expected_hte_version === nothing && !q_has_positive_evidence
        fallback = Float64(get(physical, "v8_allocator_q_max_contract",
            get(metrics, "active_q_max", 3600.0)))
        if fallback !== nothing && isfinite(fallback) && fallback > 0.0
            q_limit = fill(Float64(fallback), length(data.time))
        end
    end
    q_available = q_limit !== nothing && length(q_limit) == length(data.time) &&
        all(value -> isfinite(value) && value > 0.0, q_limit)
    command_within = q_available && all(data.command .^ 2 .<=
        reshape(q_limit, :, 1) .+ motor_tolerance)
    applied_available = data.applied !== nothing
    applied_within = q_available && applied_available && all(data.applied .^ 2 .<=
        reshape(q_limit, :, 1) .+ motor_tolerance)
    gates["required_rotation_matrix_evidence"] = rotation_available
    gates["required_rotation_orthogonality"] = rotation_available &&
        metrics["max_rotation_orthogonality_error"] <= orthogonality_limit
    gates["required_positive_rotation_determinant"] = rotation_available &&
        metrics["min_rotation_determinant"] > 0.0
    gates["required_rotation_determinant_accuracy"] = rotation_available &&
        metrics["max_rotation_determinant_error"] <= determinant_limit
    gates["required_yawless_tilt_limit"] =
        metrics["max_yawless_tilt_rad"] <= tilt_limit
    gates["required_body_rate_limit"] =
        metrics["max_abs_body_rate_radps"] <= rate_limit
    gates["required_allocator_limit_evidence"] = q_available
    gates["required_motor_command_limit"] = command_within
    gates["required_motor_applied_evidence"] = applied_available
    gates["required_motor_applied_limit"] = applied_within
    version = controller_diagnostic(table,
        diagnostic_index(config, "version_index", 16))
    version_available = version !== nothing && all(isfinite, version)
    gates["required_hte_version_evidence"] =
        expected_hte_version === nothing || version_available
    gates["required_hte_version_match"] = expected_hte_version === nothing ||
        (version_available && all(value -> value == expected_hte_version, version))
    if expected_hte_version !== nothing
        scale_hat = controller_diagnostic(table,
            diagnostic_index(config, "scale_estimate_index", 11))
        scale_apply = controller_diagnostic(table,
            diagnostic_index(config, "scale_applied_index", 12))
        fusion = controller_diagnostic(table,
            diagnostic_index(config, "fusion_valid_index", 13))
        gates["required_hte_scale_hat_projection"] = scale_hat !== nothing &&
            all(value -> 0.75 - 1.0e-12 <= value <= 1.35 + 1.0e-12, scale_hat)
        gates["required_hte_scale_apply_projection"] = scale_apply !== nothing &&
            all(value -> 0.75 - 1.0e-12 <= value <= 1.35 + 1.0e-12, scale_apply)
        gates["required_hte_fusion_flag_binary"] = fusion !== nothing &&
            all(value -> value == 0.0 || value == 1.0, fusion)
    end
    gates["all_physical_pass"] = all(values(gates))
    return gates
end

function disturbance_contract(base)
    # 扰动恢复以扰动前基线和连续保持时间共同判定。
    table, data = base.table, base.data
    forces = [optional_series(table, ["disturbanceForce[$axis]",
        "disturbance_force_$axis", "scenarioDiagnostics[$axis]"])
        for axis in 1:3]
    force_norm = if all(value -> value !== nothing, forces)
        vec(sqrt.(sum(abs2, hcat(forces...); dims=2)))
    else
        per_rotor = optional_series(table,
            ["quadChassisTest17_1.perRotorDisturbance"])
        per_rotor === nothing ? nothing : 4.0 .* abs.(per_rotor)
    end
    force_norm === nothing && return (Dict{String,Any}(
        "evidence_has_disturbance_vector" => false), false)
    segments = T7.active_segments(force_norm .> 1.0e-12)
    isempty(segments) && return (Dict{String,Any}(
        "evidence_has_disturbance_vector" => true,
        "disturbance_event_count" => 0,
        "disturbance_force_peak_n" => maximum(force_norm)), false)
    recoveries = Float64[]
    pre_rmse = Float64[]
    event_rmse = Float64[]
    for (event, (first_row, last_row)) in enumerate(segments)
        pre_start = searchsortedfirst(data.time,
            max(first(data.time), data.time[first_row] - 1.0))
        baseline_rows = pre_start:max(pre_start, first_row - 1)
        baseline = sqrt(mean(abs2, data.error[baseline_rows]))
        threshold = max(0.05, 1.25 * baseline)
        limit_row = event < length(segments) ? segments[event + 1][1] - 1 :
            length(data.time)
        recovered_at = T7.sustained_entry(data.time, data.error, last_row,
            threshold, 1.0; limit_row=limit_row)
        push!(recoveries, recovered_at === nothing ? Inf :
            recovered_at - data.time[last_row])
        push!(pre_rmse, baseline)
        push!(event_rmse, sqrt(mean(abs2, data.error[first_row:last_row])))
    end
    metrics = Dict{String,Any}(
        "evidence_has_disturbance_vector" => true,
        "disturbance_event_count" => length(segments),
        "disturbance_force_peak_n" => maximum(force_norm),
        "disturbance_pre_rmse_max_m" => maximum(pre_rmse),
        "disturbance_event_rmse_max_m" => maximum(event_rmse),
        "disturbance_recovery_time_max_s" => maximum(recoveries),
    )
    return metrics, all(isfinite, recoveries) && maximum(recoveries) <= 5.0
end

function evaluate_single_file(path; controller_id, case_id,
        config_path=default_config_path(), expected_stop=expected_stop_time(case_id),
        expected_hte_version=nothing, target_scale=nothing)
    # 单机场景按场景类型选择跟踪、扰动或透明性指标。
    isfile(path) || error("missing single-vehicle result: $path")
    isempty(strip(string(controller_id))) && error("controller_id must not be empty")
    config = load_campaign_config(config_path)
    version = validate_hte_version(expected_hte_version)
    scene = startswith(case_id, "Scene08_") ? "Scene08" :
        startswith(case_id, "Scene10_") ? "Scene10" :
        startswith(case_id, "Scene05B_") ? "Scene05B" : case_id
    base = C7.evaluate_file(path; scene=scene, expected_stop=expected_stop)
    metrics = merge(copy(base.metrics), steady_tracking_metrics(base.data))
    target = target_scale === nothing ? inferred_target_scale(base.table) :
        Float64(target_scale)
    if startswith(case_id, "Scene01S_")
        axis = findfirst(==(last(case_id)), ['X', 'Y', 'Z'])
        step = T7.evaluate_standard_step(path; axis=axis, config_path=config_path)
        merge!(metrics, step.metrics)
    end
    if case_id == "Scene06b"
        disturbance_metrics, _ = disturbance_contract(base)
        merge!(metrics, disturbance_metrics)
    end
    if version !== nothing
        merge!(metrics, hte_diagnostic_metrics(base.table, config; target_scale=target))
        if complete_v9_evidence(base.table)
            frozen_v9 = V9.evaluate_v9(path; expected_stop=expected_stop,
                target_scale=target)
            merge!(metrics, frozen_v9.metrics)
            metrics["frozen_v9_901_version_gate"] = frozen_v9.gates["version_code"]
        end
        nominal_thrust = !startswith(case_id, "Scene05B_") ||
            (target !== nothing && abs(target - 1.0) <= 1.0e-9)
        if nominal_thrust
            scale_apply = controller_diagnostic(base.table,
                diagnostic_index(config, "scale_applied_index", 12))
            false_activation_deviation = Float64(get(section(config,
                "hte_diagnostics"), "false_activation_deviation", 0.04))
            scale_apply === nothing || merge!(metrics,
                scale_transparency_metrics(base.data.time, [scale_apply];
                    deviation_threshold=false_activation_deviation))
        end
    end
    metrics["controller_id"] = string(controller_id)
    metrics["case_id"] = case_id
    metrics["evaluation_kind"] = "single_vehicle"
    metrics["expected_hte_version"] = version
    metrics["source_sha256"] = file_sha256(path)
    physical_gates = single_physical_gates(
        (; table=base.table, data=base.data, metrics), config, expected_stop, version)
    performance_gates = Dict{String,Bool}(
        "required_tracking_metrics_finite" =>
            isfinite(metrics["tracking_rmse_m"]) && isfinite(metrics["tracking_peak_m"]),
    )
    if startswith(case_id, "Scene01S_")
        performance_gates["required_step_rise_reached"] =
            metrics["rise_status"] == "reached"
        performance_gates["required_step_overshoot_limit"] =
            metrics["overshoot_percent"] <= 10.0
        performance_gates["required_step_settled"] =
            metrics["settling_status"] == "settled"
        performance_gates["required_step_steady_error"] =
            metrics["steady_abs_error_m"] <= 0.02
    elseif case_id == "Scene06b"
        recovery_limit = number(config, "comparison_gates",
            "disturbance_recovery_max_s", 5.0)
        recovery = get(metrics, "disturbance_recovery_time_max_s", nothing)
        performance_gates["required_disturbance_evidence"] =
            get(metrics, "evidence_has_disturbance_vector", false) === true
        performance_gates["required_disturbance_recovery"] =
            recovery !== nothing && isfinite(recovery) && recovery <= recovery_limit
    elseif startswith(case_id, "Scene05B_") && version !== nothing
        parameter = section(config, "parameter_gates")
        terminal_error = get(metrics, "scale_apply_terminal_relative_error", nothing)
        performance_gates["required_parameter_peak_error"] =
            metrics["tracking_peak_m"] <= Float64(get(parameter,
                "peak_error_m_max", 0.50))
        performance_gates["required_parameter_steady_error"] =
            metrics["steady_abs_error_m"] <= Float64(get(parameter,
                "steady_abs_error_m_max", 0.05))
        performance_gates["required_parameter_target_scale"] = target !== nothing
        performance_gates["required_parameter_terminal_scale"] =
            terminal_error !== nothing && terminal_error <= Float64(get(parameter,
                "terminal_scale_relative_error_max", 0.03))
    end
    if version !== nothing && get(metrics, "scale_transparency_evidence", false)
        hte = section(config, "hte_diagnostics")
        performance_gates["required_nominal_terminal_scale_transparency"] =
            metrics["terminal_scale_deviation_from_one_max"] <= Float64(get(hte,
                "terminal_nominal_scale_deviation_max", 0.02))
        performance_gates["required_no_sustained_false_activation"] =
            metrics["false_activation_continuous_duration_max_s"] < Float64(get(hte,
                "false_activation_continuous_duration_max_s", 1.0))
    end
    performance_gates["all_performance_pass"] = all(values(performance_gates))
    gates = merge(copy(physical_gates), performance_gates)
    gates["all_pass"] = physical_gates["all_physical_pass"] &&
        performance_gates["all_performance_pass"]
    return (; table=base.table, data=base.data, metrics, physical_gates,
        performance_gates, gates)
end

function formation_series(table, vehicle, index, kind)
    names = kind == :diagnostic ? ["controllerDiagnostics$vehicle[$index]"] :
        kind == :applied ? ["motorApplied$vehicle[$index]",
            "speedSensor$vehicle[$index].w"] :
        error("unsupported formation series kind: $kind")
    return optional_series(table, names)
end

function formation_physical_gates(result, config, expected_stop, expected_hte_version)
    table, data, metrics = result.table, result.data, result.metrics
    gates = time_contract_gates(table, data.time, expected_stop, config)
    physical = section(config, "physical_gates")
    orthogonality_limit = Float64(get(physical,
        "rotation_orthogonality_tolerance", 1.0e-6))
    determinant_limit = Float64(get(physical,
        "rotation_determinant_tolerance", 1.0e-6))
    motor_tolerance = Float64(get(physical, "motor_limit_tolerance", 1.0e-8))
    rotation_available = data.rotations !== nothing
    q_columns = [formation_series(table, vehicle,
        diagnostic_index(config, "allocator_qmax_index", 15), :diagnostic)
        for vehicle in 1:3]
    if expected_hte_version === nothing && all(value -> value === nothing ||
            !any(item -> isfinite(item) && item > 0.0, value), q_columns)
        q_contract = Float64(get(physical, "v8_allocator_q_max_contract", 3600.0))
        q_columns = [fill(q_contract, length(data.time)) for _ in 1:3]
    end
    q_available = all(value -> value !== nothing && length(value) == length(data.time) &&
        all(item -> isfinite(item) && item > 0.0, value), q_columns)
    command_within = q_available && all(vehicle -> all(
        data.motor[:, vehicle, :] .^ 2 .<=
            reshape(q_columns[vehicle], :, 1) .+ motor_tolerance), 1:3)
    applied_columns = [formation_series(table, vehicle, motor, :applied)
        for vehicle in 1:3, motor in 1:4]
    applied_available = all(value -> value !== nothing, applied_columns)
    applied_within = q_available && applied_available && all(vehicle ->
        all(motor -> all(applied_columns[vehicle, motor] .^ 2 .<=
            q_columns[vehicle] .+ motor_tolerance), 1:4), 1:3)
    gates["required_rotation_matrix_evidence"] = rotation_available
    gates["required_rotation_orthogonality"] = rotation_available &&
        metrics["max_rotation_orthogonality_error"] <= orthogonality_limit
    gates["required_positive_rotation_determinant"] = rotation_available &&
        metrics["min_rotation_determinant"] > 0.0
    gates["required_rotation_determinant_accuracy"] = rotation_available &&
        metrics["max_rotation_determinant_error"] <= determinant_limit
    gates["required_yawless_tilt_limit"] = rotation_available &&
        metrics["max_yawless_tilt_rad"] <= Float64(get(physical,
            "max_yawless_tilt_rad", 1.20))
    gates["required_body_rate_limit"] = metrics["max_abs_body_rate_radps"] <=
        Float64(get(physical, "max_body_rate_radps", 20.0))
    gates["required_allocator_limit_evidence"] = q_available
    gates["required_motor_command_limit"] = command_within
    gates["required_motor_applied_evidence"] = applied_available
    gates["required_motor_applied_limit"] = applied_within
    versions = [formation_series(table, vehicle,
        diagnostic_index(config, "version_index", 16), :diagnostic)
        for vehicle in 1:3]
    version_available = all(value -> value !== nothing && all(isfinite, value), versions)
    gates["required_hte_version_evidence"] =
        expected_hte_version === nothing || version_available
    gates["required_hte_version_match"] = expected_hte_version === nothing ||
        (version_available && all(items -> all(items .== expected_hte_version), versions))
    if expected_hte_version !== nothing
        diagnostic_dimension = Int(get(section(config, "hte_diagnostics"),
            "dimension", 16))
        complete_diagnostics = all(vehicle -> all(index ->
            formation_series(table, vehicle, index, :diagnostic) !== nothing,
            1:diagnostic_dimension), 1:3)
        gates["required_hte_3x16_diagnostics"] = complete_diagnostics
    end
    gates["all_physical_pass"] = all(values(gates))
    return gates
end

function evaluate_formation_file(path; controller_id, case_id,
        config_path=default_config_path(), expected_stop=expected_stop_time(case_id),
        expected_hte_version=nothing)
    # 编队评价同时保留队形精度、最小间距和安全监督代价。
    isfile(path) || error("missing formation result: $path")
    isempty(strip(string(controller_id))) && error("controller_id must not be empty")
    config = load_campaign_config(config_path)
    version = validate_hte_version(expected_hte_version)
    scene = case_id == "Scene07B" ? "Scene07B" : "Scene07C"
    frozen_context = F8.CanonicalMetricsV8.EvidenceContext(
        candidate_id=F8.CanonicalMetricsV8.SO3_V8_CANDIDATE,
        controller_id=F8.CanonicalMetricsV8.SO3_V8_CONTROLLER,
        evidence_track=F8.CanonicalMetricsV8.SO3_V8_TRACK,
        experiment_id="campaign_metrics_adapter", run_id=case_id)
    frozen = F8.evaluate_formation_file(path; context=frozen_context, scene=scene,
        expected_stop=expected_stop)
    metrics = Dict{String,Any}(key => value for (key, value) in frozen.metrics
        if !(key in PROVENANCE_KEYS))
    metrics["controller_id"] = string(controller_id)
    metrics["case_id"] = case_id
    metrics["scene"] = scene
    metrics["evaluation_kind"] = "formation"
    metrics["expected_hte_version"] = version
    metrics["source_sha256"] = file_sha256(path)
    metrics["frozen_formation_adapter"] = "FormationMetricsV8_identity_neutral_wrapper"
    if version !== nothing
        scale_columns = [formation_series(frozen.table, vehicle,
            diagnostic_index(config, "scale_applied_index", 12), :diagnostic)
            for vehicle in 1:3]
        false_activation_deviation = Float64(get(section(config,
            "hte_diagnostics"), "false_activation_deviation", 0.04))
        all(value -> value !== nothing, scale_columns) && merge!(metrics,
            scale_transparency_metrics(frozen.data.time, scale_columns;
                deviation_threshold=false_activation_deviation))
    end
    adapted = (; table=frozen.table, data=frozen.data, metrics)
    physical_gates = formation_physical_gates(adapted, config, expected_stop, version)
    comparison = section(config, "comparison_gates")
    minimum_distance = Float64(get(comparison, "formation_minimum_distance_m", 0.60))
    tracking_limit = Float64(get(comparison, "formation_rmse_max_m", 0.15))
    performance_gates = Dict{String,Bool}()
    if case_id == "Scene07B"
        performance_gates["required_minimum_pairwise_distance"] =
            metrics["minimum_pairwise_distance_m"] >= minimum_distance
        performance_gates["required_zero_safety_violation"] =
            !boolean(config, "comparison_gates", "formation_require_zero_violation", true) ||
            metrics["safety_violation_duration_s"] <= 1.0e-12
        performance_gates["required_formation_rmse"] =
            metrics["formation_rmse_m"] <= tracking_limit
        recovery = metrics["transition_recovery_time_s"]
        performance_gates["required_formation_recovery"] = recovery !== nothing &&
            isfinite(recovery) && recovery <= Float64(get(comparison,
                "formation_recovery_max_s", 5.0))
    elseif occursin("On", case_id)
        performance_gates["required_minimum_pairwise_distance"] =
            metrics["minimum_pairwise_distance_m"] >= minimum_distance
        performance_gates["required_zero_safety_violation"] =
            !boolean(config, "comparison_gates", "formation_require_zero_violation", true) ||
            metrics["safety_violation_duration_s"] <= 1.0e-12
        performance_gates["required_supervised_tracking_rmse"] =
            metrics["tracking_commanded_rmse_m"] <= tracking_limit
        active = metrics["cbf_active_fraction"]
        residual = metrics["minimum_final_hocbf_residual"]
        performance_gates["required_active_cbf"] =
            !boolean(config, "comparison_gates", "formation_require_active_cbf", true) ||
            (active !== nothing && active > 0.0)
        performance_gates["required_hocbf_residual"] = residual !== nothing &&
            residual >= Float64(get(comparison, "formation_hocbf_residual_min", -1.0e-6))
        performance_gates["required_no_infeasible_or_hold"] =
            metrics["infeasible_max"] !== nothing && metrics["hold_max"] !== nothing &&
            metrics["infeasible_max"] < 0.5 && metrics["hold_max"] < 0.5
    else
        performance_gates["required_counterfactual_collision_risk"] =
            metrics["minimum_pairwise_distance_m"] < minimum_distance &&
            metrics["safety_violation_duration_s"] > 0.0
    end
    if version !== nothing && get(metrics, "scale_transparency_evidence", false)
        hte = section(config, "hte_diagnostics")
        performance_gates["required_nominal_terminal_scale_transparency"] =
            metrics["terminal_scale_deviation_from_one_max"] <= Float64(get(hte,
                "terminal_nominal_scale_deviation_max", 0.02))
        performance_gates["required_no_sustained_false_activation"] =
            metrics["false_activation_continuous_duration_max_s"] < Float64(get(hte,
                "false_activation_continuous_duration_max_s", 1.0))
    end
    performance_gates["all_performance_pass"] = all(values(performance_gates))
    gates = merge(copy(physical_gates), performance_gates)
    gates["all_pass"] = physical_gates["all_physical_pass"] &&
        performance_gates["all_performance_pass"]
    return (; table=frozen.table, data=frozen.data, metrics, physical_gates,
        performance_gates, gates)
end

metric_or_nothing(result, key) = get(result.metrics, key, nothing)

function safe_ratio(numerator, denominator)
    # 缺失值、非有限值或零分母统一返回nothing。
    numerator === nothing && return nothing
    denominator === nothing && return nothing
    numerator = Float64(numerator)
    denominator = Float64(denominator)
    isfinite(numerator) && isfinite(denominator) && denominator > 1.0e-12 ||
        return nothing
    return numerator / denominator
end

function paired_comparison(case_id, v8, hte, config)
    # 同一场景严格配对，先检查双方物理可行性再计算性能比。
    suite = case_suite(config, case_id)
    formation = suite == "formation"
    rmse_key = formation ? "tracking_commanded_rmse_m" : "tracking_rmse_m"
    v8_rmse = metric_or_nothing(v8, rmse_key)
    hte_rmse = metric_or_nothing(hte, rmse_key)
    ratio = safe_ratio(hte_rmse, v8_rmse)
    metrics = Dict{String,Any}(
        "case_id" => case_id, "suite" => suite,
        "v8_controller_id" => v8.metrics["controller_id"],
        "hte_controller_id" => hte.metrics["controller_id"],
        "v8_tracking_rmse_m" => v8_rmse,
        "hte_tracking_rmse_m" => hte_rmse,
        "hte_v8_rmse_ratio" => ratio,
    )
    gates = Dict{String,Bool}(
        "required_v8_physical_pass" => v8.physical_gates["all_physical_pass"],
        "required_hte_physical_pass" => hte.physical_gates["all_physical_pass"],
        "required_paired_rmse_evaluable" => ratio !== nothing,
    )
    comparison = section(config, "comparison_gates")
    if suite == "main_single"
        gates["required_main_broad_regression"] = ratio !== nothing && ratio <=
            Float64(get(comparison, "main_task_broad_regression_ratio", 1.10))
        if case_id == "Scene04"
            gates["required_nominal_regression"] = ratio !== nothing && ratio <=
                Float64(get(comparison, "nominal_rmse_ratio_vs_v8_max", 1.02))
        elseif case_id == "Scene06b"
            v8_recovery = metric_or_nothing(v8, "disturbance_recovery_time_max_s")
            hte_recovery = metric_or_nothing(hte, "disturbance_recovery_time_max_s")
            recovery_ratio = safe_ratio(hte_recovery, v8_recovery)
            metrics["v8_disturbance_recovery_s"] = v8_recovery
            metrics["hte_disturbance_recovery_s"] = hte_recovery
            metrics["hte_v8_disturbance_recovery_ratio"] = recovery_ratio
            gates["required_disturbance_recovery_absolute"] = hte_recovery !== nothing &&
                isfinite(hte_recovery) && hte_recovery <= Float64(get(comparison,
                    "disturbance_recovery_max_s", 5.0))
            gates["required_disturbance_recovery_pair"] = recovery_ratio !== nothing &&
                recovery_ratio <= Float64(get(comparison,
                    "disturbance_recovery_ratio_vs_v8_max", 1.10))
        end
    elseif suite == "standard_steps"
        gates["required_nominal_regression"] = ratio !== nothing && ratio <=
            Float64(get(comparison, "nominal_rmse_ratio_vs_v8_max", 1.02))
    elseif suite == "parameter"
        gates["required_parameter_pair_regression"] = ratio !== nothing && ratio <=
            number(config, "parameter_gates", "per_case_rmse_ratio_vs_v8_max", 1.02)
    elseif formation
        gates["required_formation_performance"] =
            hte.performance_gates["all_performance_pass"]
    end
    gates["all_pair_pass"] = all(values(gates))
    return Dict{String,Any}("metrics" => metrics, "gates" => gates)
end

function locate_case_file(root, case_id)
    direct = joinpath(root, case_id * ".csv")
    isfile(direct) && return abspath(direct)
    raw = joinpath(root, "raw", case_id * ".csv")
    isfile(raw) && return abspath(raw)
    matches = String[]
    for (directory, _, files) in walkdir(root)
        case_id * ".csv" in files && push!(matches,
            abspath(joinpath(directory, case_id * ".csv")))
    end
    length(matches) == 1 || error(
        "expected exactly one $case_id.csv under $root, found $(length(matches))")
    return only(matches)
end

function result_row(case_id, suite, role, result, raw_path)
    return Dict{String,Any}(
        "case_id" => case_id, "suite" => suite, "role" => role,
        "controller_id" => result.metrics["controller_id"],
        "expected_hte_version" => result.metrics["expected_hte_version"],
        "raw_path" => raw_path, "raw_sha256" => result.metrics["source_sha256"],
        "tracking_rmse_m" => get(result.metrics, "tracking_rmse_m", nothing),
        "tracking_commanded_rmse_m" =>
            get(result.metrics, "tracking_commanded_rmse_m", nothing),
        "tracking_peak_m" => get(result.metrics, "tracking_peak_m", nothing),
        "steady_abs_error_m" => get(result.metrics, "steady_abs_error_m", nothing),
        "disturbance_recovery_time_max_s" =>
            get(result.metrics, "disturbance_recovery_time_max_s", nothing),
        "minimum_pairwise_distance_m" =>
            get(result.metrics, "minimum_pairwise_distance_m", nothing),
        "formation_rmse_m" => get(result.metrics, "formation_rmse_m", nothing),
        "all_physical_pass" => result.physical_gates["all_physical_pass"],
        "all_performance_pass" => result.performance_gates["all_performance_pass"],
        "all_pass" => result.gates["all_pass"],
    )
end

function aggregate_ratio_gate(pairs, case_ids, limit)
    selected = [pairs[case_id]["metrics"]["hte_v8_rmse_ratio"] for case_id in case_ids
        if haskey(pairs, case_id)]
    return length(selected) == length(case_ids) && all(value ->
        value !== nothing && isfinite(value), selected) && mean(selected) <= limit
end

function evaluate_campaign(v8_root, hte_root; config_path=default_config_path(),
        hte_controller_id="RA-GCA-CGHTE", expected_hte_version=914,
        selected_cases=nothing)
    # 全部注册工况完成后再汇总配对门和项目级结论。
    isdir(v8_root) || error("missing V8 result root: $v8_root")
    isdir(hte_root) || error("missing formal-controller result root: $hte_root")
    config = load_campaign_config(config_path)
    version = validate_hte_version(expected_hte_version)
    all_cases = suite_case_ids(config)
    cases = selected_cases === nothing ? all_cases : String.(selected_cases)
    isempty(cases) && error("campaign selection is empty")
    unknown = setdiff(cases, all_cases)
    isempty(unknown) || error("unregistered campaign cases: $(join(unknown, ", "))")
    results = Dict{String,Any}()
    pairs = Dict{String,Any}()
    rows = Dict{String,Any}[]
    for case_id in cases
        suite = case_suite(config, case_id)
        v8_path = locate_case_file(v8_root, case_id)
        hte_path = locate_case_file(hte_root, case_id)
        if suite == "formation"
            v8 = evaluate_formation_file(v8_path; controller_id="RA-GCA/V8",
                case_id, config_path, expected_hte_version=nothing)
            hte = evaluate_formation_file(hte_path; controller_id=hte_controller_id,
                case_id, config_path, expected_hte_version=version)
        else
            v8 = evaluate_single_file(v8_path; controller_id="RA-GCA/V8",
                case_id, config_path, expected_hte_version=nothing)
            hte = evaluate_single_file(hte_path; controller_id=hte_controller_id,
                case_id, config_path, expected_hte_version=version)
        end
        results[case_id] = Dict("v8" => v8, "hte" => hte)
        pairs[case_id] = paired_comparison(case_id, v8, hte, config)
        push!(rows, result_row(case_id, suite, "v8", v8, v8_path))
        push!(rows, result_row(case_id, suite, "hte", hte, hte_path))
    end
    suite = section(config, "suite")
    wind_cases = String.(get(suite, "wind", String[]))
    sensor_cases = String.(get(suite, "sensor", String[]))
    parameter_cases = String.(get(suite, "parameter", String[]))
    comparison = section(config, "comparison_gates")
    parameter = section(config, "parameter_gates")
    physical_pass = all(row["all_physical_pass"] === true for row in rows)
    pair_pass = all(pair["gates"]["all_pair_pass"] === true for pair in values(pairs))
    parameter_complete = all(case_id -> haskey(results, case_id), parameter_cases)
    parameter_retention = false
    mismatch_improvement = false
    if parameter_complete && haskey(results, "Scene05B_Nominal")
        nominal_rmse = results["Scene05B_Nominal"]["hte"].metrics["tracking_rmse_m"]
        retentions = [results[case_id]["hte"].metrics["tracking_rmse_m"] / nominal_rmse
            for case_id in parameter_cases]
        parameter_retention = all(value -> value <= Float64(get(parameter,
            "retention_excellence_max", 2.0)), retentions)
        mismatch_cases = [case_id for case_id in parameter_cases if begin
            target = get(results[case_id]["hte"].metrics, "expected_target_scale", nothing)
            target !== nothing && abs(target - 1.0) > 1.0e-9
        end]
        improvements = [1.0 - pairs[case_id]["metrics"]["hte_v8_rmse_ratio"]
            for case_id in mismatch_cases]
        mismatch_improvement = !isempty(improvements) && median(improvements) >=
            Float64(get(parameter, "mismatch_median_rmse_improvement_min", 0.50))
    end
    formation_cost = false
    if haskey(results, "Scene07COff") && haskey(results, "Scene07COnPredictiveV5C")
        off_rmse = results["Scene07COff"]["hte"].metrics["tracking_commanded_rmse_m"]
        on_rmse = results["Scene07COnPredictiveV5C"]["hte"].metrics[
            "tracking_commanded_rmse_m"]
        cost_ratio = safe_ratio(on_rmse, off_rmse)
        formation_cost = cost_ratio !== nothing && cost_ratio <= 1.0 + Float64(get(
            comparison, "formation_tracking_cost_increase_max", 0.35))
    end
    summary_gates = Dict{String,Bool}(
        "required_full_suite_coverage" => Set(cases) == Set(all_cases),
        "required_all_physical_gates" => physical_pass,
        "required_all_paired_case_gates" => pair_pass,
        "required_wind_mean_pair_gate" => aggregate_ratio_gate(pairs, wind_cases,
            Float64(get(comparison, "wind_mean_rmse_ratio_vs_v8_max", 1.05))),
        "required_sensor_mean_pair_gate" => aggregate_ratio_gate(pairs, sensor_cases,
            Float64(get(comparison, "sensor_mean_rmse_ratio_vs_v8_max", 1.05))),
        "required_parameter_retention" => parameter_retention,
        "required_parameter_mismatch_improvement" => mismatch_improvement,
        "required_formation_tracking_cost" => formation_cost,
    )
    summary_gates["all_pass"] = all(values(summary_gates))
    critical_phase1 = all(get(summary_gates, key, false) for key in (
        "required_full_suite_coverage", "required_all_physical_gates",
        "required_all_paired_case_gates", "required_wind_mean_pair_gate",
        "required_sensor_mean_pair_gate", "required_formation_tracking_cost"))
    phase1_decision = summary_gates["all_pass"] ? "candidate" :
        critical_phase1 ? "optimize" : "retain_v8"
    pair_rows = [merge(copy(pair["metrics"]), Dict(
        "all_pair_pass" => pair["gates"]["all_pair_pass"]))
        for pair in values(pairs)]
    sort!(pair_rows; by=row -> row["case_id"])
    return Dict{String,Any}(
        "schema_version" => 1, "campaign" => config["campaign"],
        "generated_utc" => Dates.format(now(UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sssZ"),
        "syslab_julia_version" => string(VERSION),
        "hte_controller_id" => string(hte_controller_id),
        "expected_hte_version" => version, "config_path" => abspath(config_path),
        "config_sha256" => file_sha256(config_path),
        "phase1_decision" => phase1_decision,
        "frozen_sources" => frozen_source_manifest(), "selected_cases" => cases,
        "case_rows" => rows, "pair_rows" => pair_rows,
        "summary_gates" => summary_gates,
    )
end

function backup_existing(path)
    isfile(path) || return nothing
    stamp = Dates.format(now(UTC), dateformat"yyyymmddTHHMMSSsssZ")
    backup = path * ".bak." * stamp
    suffix = 0
    while ispath(backup)
        suffix += 1
        backup = path * ".bak." * stamp * "." * string(suffix)
    end
    mv(path, backup)
    return backup
end

function atomic_write(writer, path)
    # 先写临时文件再替换目标，避免中断留下半份结果。
    mkpath(dirname(path))
    temporary = path * ".tmp"
    ispath(temporary) && error("refusing to overwrite stale temporary file: $temporary")
    backup = backup_existing(path)
    try
        writer(temporary)
        mv(temporary, path)
    catch
        if isfile(temporary)
            mv(temporary, temporary * ".failed." *
                Dates.format(now(UTC), dateformat"yyyymmddTHHMMSSsssZ"))
        end
        backup === nothing || mv(backup, path)
        rethrow()
    end
    return backup
end

function write_json_byte_escape(stream, byte)
    if byte == UInt8('"')
        write(stream, "\\\"")
    elseif byte == UInt8('\\')
        write(stream, "\\\\")
    elseif byte == 0x08
        write(stream, "\\b")
    elseif byte == 0x09
        write(stream, "\\t")
    elseif byte == 0x0a
        write(stream, "\\n")
    elseif byte == 0x0c
        write(stream, "\\f")
    elseif byte == 0x0d
        write(stream, "\\r")
    elseif 0x20 <= byte <= 0x7e
        write(stream, byte)
    else
        write(stream, "\\u00", uppercase(string(byte; base=16, pad=2)))
    end
end

function strict_json_string(value)
    text = string(value)
    stream = IOBuffer()
    write(stream, '"')
    if isvalid(text)
        for character in text
            if character == '"'
                write(stream, "\\\"")
            elseif character == '\\'
                write(stream, "\\\\")
            elseif character == '\b'
                write(stream, "\\b")
            elseif character == '\t'
                write(stream, "\\t")
            elseif character == '\n'
                write(stream, "\\n")
            elseif character == '\f'
                write(stream, "\\f")
            elseif character == '\r'
                write(stream, "\\r")
            elseif Int(character) < 0x20
                write(stream, "\\u", uppercase(string(Int(character); base=16, pad=4)))
            else
                write(stream, character)
            end
        end
    else
        foreach(byte -> write_json_byte_escape(stream, byte), codeunits(text))
    end
    write(stream, '"')
    return String(take!(stream))
end

function strict_json_value(value, indent=0)
    value === nothing && return "null"
    value isa Bool && return value ? "true" : "false"
    value isa Integer && return string(value)
    value isa AbstractFloat && return isfinite(value) ? string(value) : "null"
    value isa AbstractString && return strict_json_string(value)
    if value isa AbstractDict
        keys_ordered = sort!(collect(keys(value)); by=string)
        isempty(keys_ordered) && return "{}"
        fields = [repeat(" ", indent + 2) * strict_json_string(key) * ": " *
            strict_json_value(value[key], indent + 2) for key in keys_ordered]
        return "{\n" * join(fields, ",\n") * "\n" * repeat(" ", indent) * "}"
    end
    if value isa AbstractVector
        isempty(value) && return "[]"
        fields = [repeat(" ", indent + 2) * strict_json_value(item, indent + 2)
            for item in value]
        return "[\n" * join(fields, ",\n") * "\n" * repeat(" ", indent) * "]"
    end
    error("unsupported JSON value: $(typeof(value))")
end

function write_json_atomic(path, value)
    return atomic_write(path) do temporary
        open(temporary, "w") do stream
            println(stream, strict_json_value(value))
        end
    end
end

function write_table_atomic(path, columns, rows)
    return atomic_write(path) do temporary
        open(temporary, "w") do stream
            println(stream, join(C7.csv_escape.(columns), ','))
            for row in rows
                println(stream, join([C7.csv_escape(get(row, column, nothing))
                    for column in columns], ','))
            end
        end
    end
end

function write_campaign_outputs(summary, output_root)
    # JSON、场景表和配对表使用同一评价结果生成。
    case_columns = ["case_id", "suite", "role", "controller_id",
        "expected_hte_version", "raw_path", "raw_sha256", "tracking_rmse_m",
        "tracking_commanded_rmse_m", "tracking_peak_m", "steady_abs_error_m",
        "disturbance_recovery_time_max_s", "minimum_pairwise_distance_m",
        "formation_rmse_m", "all_physical_pass", "all_performance_pass", "all_pass"]
    pair_columns = ["case_id", "suite", "v8_controller_id", "hte_controller_id",
        "v8_tracking_rmse_m", "hte_tracking_rmse_m", "hte_v8_rmse_ratio",
        "v8_disturbance_recovery_s", "hte_disturbance_recovery_s",
        "hte_v8_disturbance_recovery_ratio", "all_pair_pass"]
    gate_rows = [Dict("gate" => key, "pass" => value)
        for (key, value) in summary["summary_gates"]]
    sort!(gate_rows; by=row -> row["gate"])
    paths = Dict{String,Any}(
        "summary_json" => joinpath(output_root, "campaign_evaluation.json"),
        "cases_csv" => joinpath(output_root, "campaign_cases.csv"),
        "pairs_csv" => joinpath(output_root, "campaign_pairs.csv"),
        "gates_csv" => joinpath(output_root, "campaign_gates.csv"),
    )
    backups = Dict{String,Any}()
    backups["summary_json"] = write_json_atomic(paths["summary_json"], summary)
    backups["cases_csv"] = write_table_atomic(paths["cases_csv"], case_columns,
        summary["case_rows"])
    backups["pairs_csv"] = write_table_atomic(paths["pairs_csv"], pair_columns,
        summary["pair_rows"])
    backups["gates_csv"] = write_table_atomic(paths["gates_csv"], ["gate", "pass"],
        gate_rows)
    paths["backups"] = backups
    return paths
end

end
