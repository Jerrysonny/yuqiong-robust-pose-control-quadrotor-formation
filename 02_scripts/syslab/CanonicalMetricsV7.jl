module CanonicalMetricsV7

using Statistics
using TOML

export NumericTable, evaluate_file, infer_scene, read_numeric_csv, write_outputs,
    canonicalize, find_series, trapezoid, write_row_csv, write_json, scene01_dynamics

struct NumericTable
    names::Vector{String}
    columns::Dict{String,Vector{Float64}}
    nrows::Int
end

const AXES = ("x", "y", "z")
const ATTITUDE = ("roll", "pitch", "yaw")

function split_csv_line(line::AbstractString)
    fields = String[]
    buffer = IOBuffer()
    quoted = false
    index = firstindex(line)
    while index <= lastindex(line)
        character = line[index]
        if character == '"'
            following = nextind(line, index)
            if quoted && following <= lastindex(line) && line[following] == '"'
                write(buffer, '"')
                index = following
            else
                quoted = !quoted
            end
        elseif character == ',' && !quoted
            push!(fields, String(take!(buffer)))
        else
            write(buffer, character)
        end
        index = nextind(line, index)
    end
    quoted && error("unterminated quoted CSV field")
    push!(fields, String(take!(buffer)))
    return fields
end

function read_numeric_csv(path::AbstractString)
    # 仅接受数值列和唯一表头，避免静默吞掉损坏的仿真结果。
    open(path, "r") do stream
        eof(stream) && error("empty CSV: $path")
        names = split_csv_line(readline(stream))
        names[1] = replace(names[1], '\ufeff' => "")
        length(unique(names)) == length(names) || error("duplicate CSV columns: $path")
        columns = Dict(name => Float64[] for name in names)
        row_number = 1
        while !eof(stream)
            line = readline(stream)
            isempty(strip(line)) && continue
            row_number += 1
            fields = split_csv_line(line)
            length(fields) == length(names) ||
                error("$path:$row_number has $(length(fields)) fields, expected $(length(names))")
            for (name, field) in zip(names, fields)
                parsed = isempty(strip(field)) ? NaN : tryparse(Float64, strip(field))
                parsed === nothing && error("$path:$row_number nonnumeric value in $name: $field")
                push!(columns[name], parsed)
            end
        end
        rows = length(columns[names[1]])
        rows > 0 || error("CSV has no data rows: $path")
        return NumericTable(names, columns, rows)
    end
end

function find_series(table, candidates; required=true)
    for candidate in candidates
        haskey(table.columns, candidate) && return table.columns[candidate]
    end
    required && error("missing required column; accepted names: $(join(candidates, ", "))")
    return nothing
end

function component_series(table, family, index)
    axis = AXES[index]
    candidates = if family == :reference
        ["referenceVector[$index]", "ref_$axis", "reference_$axis", "reference_$(axis)_m"]
    elseif family == :position
        ["quadChassisTest17_1.body.r_0[$index]", "pos_$axis", "position_$axis", "position_$(axis)_m"]
    elseif family == :attitude
        name = ATTITUDE[index]
        ["sensors1_1.AngleMea[$index]", "att_$name", "attitude_$name", name]
    elseif family == :rate
        ["quadChassisTest17_1.body.frame_b.R.w[$index]", "omega_$axis", "body_rate_$axis"]
    else
        error("unknown component family: $family")
    end
    return find_series(table, candidates)
end

function motor_series(table, index, kind; required=true)
    candidates = kind == :command ?
        ["motorCommand[$index]", "motor_command_$index", "motor_$index"] :
        ["motorApplied[$index]", "motor_applied_$index", "speedSensor[$index].w"]
    return find_series(table, candidates; required=required)
end

matrix_columns(columns) = hcat(columns...)

function optional_diagnostic(table, index, aliases=String[])
    return find_series(table, vcat(["controllerDiagnostics[$index]"], aliases); required=false)
end

function positive_limit(value)
    value === nothing && return nothing
    parsed = try
        Float64(value)
    catch
        return nothing
    end
    return isfinite(parsed) && parsed > 0.0 ? parsed : nothing
end

function positive_diagnostic_limit(values)
    values === nothing && return nothing
    valid = filter(value -> isfinite(value) && value > 0.0, values)
    return isempty(valid) ? nothing : maximum(valid)
end

function canonicalize(table)
    # 将不同包装模型的列名统一为参考、状态、旋转矩阵和执行器序列。
    time = find_series(table, ["time", "Time", "t", "time_s"])
    reference = matrix_columns([component_series(table, :reference, index) for index in 1:3])
    position = matrix_columns([component_series(table, :position, index) for index in 1:3])
    attitude = matrix_columns([component_series(table, :attitude, index) for index in 1:3])
    rates = matrix_columns([component_series(table, :rate, index) for index in 1:3])
    rotation_columns = [find_series(table, [
        "quadChassisTest17_1.body.frame_b.R.T[$row,$column]",
        "rotationMatrix[$row,$column]", "rotation_r$(row)$(column)"];
        required=false) for row in 1:3 for column in 1:3]
    rotation_count = count(column -> column !== nothing, rotation_columns)
    rotation_count in (0, 9) || error("partial rotation matrix evidence: expected zero or nine columns")
    rotation = rotation_count == 0 ? nothing : matrix_columns(rotation_columns)
    command = matrix_columns([motor_series(table, index, :command) for index in 1:4])
    applied_columns = [motor_series(table, index, :applied; required=false) for index in 1:4]
    applied_count = count(column -> column !== nothing, applied_columns)
    applied_count in (0, 4) || error("partial motorApplied capability: expected zero or four columns")
    applied = applied_count == 0 ? nothing : matrix_columns(applied_columns)
    error = vec(sqrt.(sum(abs2, position - reference; dims=2)))
    tilt = acos.(clamp.(cos.(attitude[:, 1]) .* cos.(attitude[:, 2]), -1.0, 1.0))
    return (; time, reference, position, attitude, rates, rotation, command, applied, error, tilt)
end

function rotation_quality(rotation)
    # 同时检查正交误差和行列式，防止仅凭欧拉角遗漏姿态异常。
    rotation === nothing && return nothing
    orthogonality = Float64[]
    determinants = Float64[]
    for row in axes(rotation, 1)
        value(i, j) = rotation[row, 3 * (i - 1) + j]
        squared_error = 0.0
        for i in 1:3, j in 1:3
            gram = sum(value(k, i) * value(k, j) for k in 1:3)
            squared_error += (gram - (i == j ? 1.0 : 0.0))^2
        end
        determinant =
            value(1, 1) * (value(2, 2) * value(3, 3) - value(2, 3) * value(3, 2)) -
            value(1, 2) * (value(2, 1) * value(3, 3) - value(2, 3) * value(3, 1)) +
            value(1, 3) * (value(2, 1) * value(3, 2) - value(2, 2) * value(3, 1))
        push!(orthogonality, sqrt(squared_error))
        push!(determinants, determinant)
    end
    return (; orthogonality, determinants)
end

function indexed_dimension(table, prefix)
    pattern = Regex("^" * prefix * raw"\[(\d+)\]$")
    indices = Int[]
    for name in table.names
        matched = match(pattern, name)
        matched === nothing || push!(indices, parse(Int, matched.captures[1]))
    end
    return isempty(indices) ? 0 : maximum(indices)
end

trapezoid(values, time) = sum((values[1:end-1] .+ values[2:end]) .* diff(time) .* 0.5)

function motor_smoothness(motors, time)
    differences = diff(motors; dims=1)
    duration = time[end] - time[1]
    total_variation = sum(abs, differences)
    dt = diff(time)
    slew = differences ./ reshape(dt, :, 1)
    weights = repeat(dt, 1, size(motors, 2))
    rms_slew = sqrt(sum(abs2.(slew) .* weights) / sum(weights))
    return (total_variation=total_variation,
        variation_rate=total_variation / duration,
        rms_slew_rate=rms_slew,
        max_slew_rate=maximum(abs, slew))
end

function motion_segments(reference; tolerance=1e-9)
    moving = vec(sqrt.(sum(abs2, diff(reference; dims=1); dims=2))) .> tolerance
    segments = Tuple{Int,Int}[]
    index = 1
    while index <= length(moving)
        if moving[index]
            start_row = index
            while index < length(moving) && moving[index + 1]
                index += 1
            end
            push!(segments, (start_row, index + 1))
        end
        index += 1
    end
    return segments
end

function first_crossing(values, threshold, direction, first_row, last_row)
    for row in first_row:last_row
        direction * (values[row] - threshold) >= 0 && return row
    end
    return nothing
end

function scene01_dynamics(data)
    segments = motion_segments(data.reference)
    isempty(segments) && return Dict{String,Any}(
        "scene01_reference_event_count" => 0,
        "scene01_worst_rise_time_10_90_s" => nothing,
        "scene01_peak_overshoot_m" => 0.0,
        "scene01_last_motion_end_s" => data.time[1],
        "scene01_settling_band_m" => 0.05,
        "scene01_settling_time_s" => 0.0)

    rise_times = Float64[]
    peak_overshoot = 0.0
    for (event, (start_row, end_row)) in enumerate(segments)
        delta = data.reference[end_row, :] - data.reference[start_row, :]
        axis = argmax(abs.(delta))
        abs(delta[axis]) <= 1e-12 && continue
        direction = sign(delta[axis])
        initial = data.reference[start_row, axis]
        target = data.reference[end_row, axis]
        search_end = event < length(segments) ? segments[event + 1][1] : length(data.time)
        row10 = first_crossing(data.position[:, axis], initial + 0.1 * delta[axis],
            direction, start_row, search_end)
        row90 = first_crossing(data.position[:, axis], initial + 0.9 * delta[axis],
            direction, start_row, search_end)
        if row10 !== nothing && row90 !== nothing && row90 >= row10
            push!(rise_times, data.time[row90] - data.time[row10])
        end
        overshoot = maximum(direction .* (data.position[end_row:search_end, axis] .- target))
        peak_overshoot = max(peak_overshoot, overshoot, 0.0)
    end

    last_end = segments[end][2]
    initial_reference = reshape(data.reference[1, :], 1, :)
    amplitude = maximum(vec(sqrt.(sum(abs2, data.reference .- initial_reference; dims=2))))
    settling_band = max(0.05, 0.02 * amplitude)
    violating = findall(data.error[last_end:end] .> settling_band)
    settling_time = if isempty(violating)
        0.0
    elseif violating[end] == length(data.time) - last_end + 1
        Inf
    else
        data.time[last_end + violating[end]] - data.time[last_end]
    end
    return Dict{String,Any}(
        "scene01_reference_event_count" => length(segments),
        "scene01_worst_rise_time_10_90_s" => isempty(rise_times) ? nothing : maximum(rise_times),
        "scene01_peak_overshoot_m" => peak_overshoot,
        "scene01_last_motion_end_s" => data.time[last_end],
        "scene01_settling_band_m" => settling_band,
        "scene01_settling_time_s" => settling_time)
end

function infer_scene(path)
    stem = lowercase(splitext(basename(path))[1])
    patterns = ((r"scene[_-]?0*1s[_-]?x(?:[^a-z0-9]|$)", "Scene01S_X"),
        (r"scene[_-]?0*1s[_-]?y(?:[^a-z0-9]|$)", "Scene01S_Y"),
        (r"scene[_-]?0*1s[_-]?z(?:[^a-z0-9]|$)", "Scene01S_Z"),
        (r"scene[_-]?0*1(?:[^0-9a-z]|$)", "Scene01"),
        (r"scene[_-]?0*2(?:[^0-9]|$)", "Scene02"),
        (r"scene[_-]?0*3(?:[^0-9]|$)", "Scene03"),
        (r"scene[_-]?0*4(?:[^0-9]|$)", "Scene04"),
        (r"scene[_-]?0*5b(?:[^0-9]|$)", "Scene05B"),
        (r"scene[_-]?0*6b(?:[^0-9]|$)", "Scene06b"),
        (r"scene[_-]?0*7b(?:[^0-9]|$)", "Scene07B"),
        (r"scene[_-]?0*7c(?:[^0-9]|$)", "Scene07C"),
        (r"scene[_-]?0*8(?:[^0-9]|$)", "Scene08"),
        (r"scene[_-]?0*9a(?:[^0-9]|$)", "Scene09A"),
        (r"scene[_-]?0*9b(?:[^0-9]|$)", "Scene09B"),
        (r"scene[_-]?0*10(?:[^0-9]|$)", "Scene10"))
    for (pattern, scene) in patterns
        occursin(pattern, stem) && return scene
    end
    return "Unknown"
end

function config_value(config, path, default)
    current = config
    for key in path
        current isa AbstractDict || return default
        haskey(current, key) || return default
        current = current[key]
    end
    return current
end

function expected_stop_time(config, scene)
    configured = config_value(config, ["scene", scene, "stop_time_s"], nothing)
    configured !== nothing && return Float64(configured)
    scene == "Scene04" && return 30.0
    startswith(scene, "Scene01S_") && return 30.0
    scene == "Scene06b" && return 30.0
    scene == "Scene03" && return 120.0
    scene in ("Scene09A", "Scene09B") && return 45.0
    return 50.0
end

# 所有单机场景从同一规范化入口生成指标和基础门。
function evaluate_file(path; scene=infer_scene(path), config_path=nothing,
        expected_stop=nothing, q_max=nothing, baseline_rmse=nothing)
    table = read_numeric_csv(path)
    data = canonicalize(table)
    config = config_path === nothing ? Dict{String,Any}() : TOML.parsefile(config_path)
    finite = all(name -> all(isfinite, table.columns[name]), table.names)
    increasing = all(diff(data.time) .> 0.0)
    stop_time = expected_stop === nothing ? expected_stop_time(config, scene) : Float64(expected_stop)
    rmse = sqrt(mean(abs2, data.error))
    smoothness = motor_smoothness(data.command, data.time)
    rotation = rotation_quality(data.rotation)
    explicit_q = positive_limit(q_max)
    configured_q = positive_limit(config_value(config, ["scene", scene, "q_max"], nothing))
    controller_q = positive_diagnostic_limit(
        optional_diagnostic(table, 15, ["q_max_diagnostic", "q_max"]))
    scenario_q = positive_diagnostic_limit(
        find_series(table, ["scenarioDiagnostics[10]"]; required=false))
    active_q_max = something(explicit_q, configured_q, controller_q, scenario_q, 3600.0)
    allocator = optional_diagnostic(table, 8, ["clipping_flag", "allocator_active"])
    residual = optional_diagnostic(table, 7, ["allocation_residual_norm"])
    command_q = maximum(abs2, data.command)
    has_applied = data.applied !== nothing
    has_scenario = any(startswith(name, "scenarioDiagnostics[") for name in table.names)
    diagnostic_dimension = indexed_dimension(table, "controllerDiagnostics")
    applied_q = has_applied ? maximum(abs2, data.applied) : nothing
    external_clip = has_applied ?
        mean(vec(maximum(abs.(data.command .^ 2 .- data.applied .^ 2); dims=2)) .> 1e-8) : nothing

    metrics = Dict{String,Any}(
        "scene" => scene, "source_file" => abspath(path), "samples" => table.nrows,
        "stop_time_s" => data.time[end], "tracking_rmse_m" => rmse,
        "tracking_iae_m_s" => trapezoid(data.error, data.time),
        "tracking_ise_m2_s" => trapezoid(abs2.(data.error), data.time),
        "tracking_p95_m" => quantile(data.error, 0.95),
        "tracking_peak_m" => maximum(data.error), "tracking_final_m" => data.error[end],
        "max_yawless_tilt_rad" => maximum(data.tilt),
        "max_abs_body_rate_radps" => maximum(abs, data.rates),
        "max_rotation_orthogonality_error" => rotation === nothing ? nothing : maximum(rotation.orthogonality),
        "min_rotation_determinant" => rotation === nothing ? nothing : minimum(rotation.determinants),
        "max_rotation_determinant_error" => rotation === nothing ? nothing : maximum(abs.(rotation.determinants .- 1.0)),
        "max_motor_command_q" => command_q, "max_motor_applied_q" => applied_q,
        "active_q_max" => active_q_max, "external_clip_fraction" => external_clip,
        "motor_total_variation" => smoothness.total_variation,
        "motor_variation_per_second" => smoothness.variation_rate,
        "motor_rms_slew_rate" => smoothness.rms_slew_rate,
        "motor_max_slew_rate" => smoothness.max_slew_rate,
        "allocator_active_fraction" => allocator === nothing ? nothing : mean(allocator .> 0.5),
        "allocation_residual_rms" => residual === nothing ? nothing : sqrt(mean(abs2, residual)),
        "allocation_residual_peak" => residual === nothing ? nothing : maximum(abs, residual),
        "baseline_rmse_m" => baseline_rmse,
        "rmse_ratio_vs_baseline" => baseline_rmse === nothing ? nothing : rmse / Float64(baseline_rmse),
        "evidence_has_motor_command" => true,
        "evidence_has_rotation_matrix" => rotation !== nothing,
        "evidence_has_motor_applied" => has_applied,
        "evidence_has_scenario_diagnostics" => has_scenario,
        "evidence_controller_diagnostics_dimension" => diagnostic_dimension,
        "evidence_external_clip_evaluable" => has_applied,
        "evidence_applied_limit_evaluable" => has_applied)
    scene == "Scene01" && merge!(metrics, scene01_dynamics(data))

    tilt_limit = Float64(config_value(config, ["global_gates", "max_yawless_tilt_rad"],
        config_value(config, ["global_gates", "max_tilt_rad"], 1.2)))
    rate_limit = Float64(config_value(config, ["global_gates", "max_body_rate_radps"], 20.0))
    rotation_tolerance = Float64(config_value(config,
        ["global_gates", "rotation_orthogonality_tolerance"], 1e-6))
    require_applied = Bool(config_value(config,
        ["global_gates", "motor_applied_within_limit"], false))
    require_scenario = scene in ("Scene05B", "Scene06b", "Scene08", "Scene09B", "Scene10")
    gates = Dict{String,Any}(
        "scene" => scene, "finite" => finite, "strictly_increasing_time" => increasing,
        "start_at_zero" => abs(data.time[1]) <= 1e-12,
        "stop_time_contract" => abs(data.time[end] - stop_time) <= 1e-8,
        "yawless_tilt_le_limit" => maximum(data.tilt) <= tilt_limit,
        "body_rate_le_limit" => maximum(abs, data.rates) <= rate_limit,
        "required_rotation_matrix_evidence" => rotation !== nothing,
        "rotation_orthogonality_le_tolerance" => rotation !== nothing &&
            maximum(rotation.orthogonality) <= rotation_tolerance,
        "rotation_determinant_positive" => rotation !== nothing && minimum(rotation.determinants) > 0.0,
        "rotation_determinant_error_le_tolerance" => rotation !== nothing &&
            maximum(abs.(rotation.determinants .- 1.0)) <= rotation_tolerance,
        "motor_command_within_q_limit" => command_q <= active_q_max + 1e-8,
        "motor_applied_within_q_limit" => has_applied ? applied_q <= active_q_max + 1e-8 : nothing,
        "required_motor_applied_evidence" => !require_applied || has_applied,
        "required_scenario_evidence" => !require_scenario || has_scenario,
        "controller_diagnostics_dimension" => diagnostic_dimension)
    baseline_rmse !== nothing &&
        (gates["nominal_regression_le_2pct"] = rmse / Float64(baseline_rmse) <= 1.02)
    gates["all_pass"] = all(value for (key, value) in gates
        if key != "scene" && value isa Bool)
    return (; table, data, metrics, gates)
end

function csv_escape(value)
    text = value === nothing ? "" : string(value)
    if occursin(',', text) || occursin('"', text) || occursin('\n', text) || occursin('\r', text)
        return "\"" * replace(text, "\"" => "\"\"") * "\""
    end
    return text
end

function write_row_csv(path, row)
    mkpath(dirname(path))
    ordered = sort!(collect(keys(row)))
    open(path, "w") do stream
        println(stream, join(csv_escape.(ordered), ','))
        println(stream, join([csv_escape(row[key]) for key in ordered], ','))
    end
end

function json_escape(text)
    escaped = replace(string(text), '\\' => "\\\\", '"' => "\\\"",
        '\n' => "\\n", '\r' => "\\r", '\t' => "\\t")
    return "\"$escaped\""
end

function json_value(value, indent=0)
    value === nothing && return "null"
    value isa Bool && return value ? "true" : "false"
    value isa Integer && return string(value)
    value isa AbstractFloat && return isfinite(value) ? string(value) : "null"
    value isa AbstractString && return json_escape(value)
    if value isa AbstractDict
        ordered = sort!(collect(keys(value)); by=string)
        isempty(ordered) && return "{}"
        fields = [repeat(" ", indent + 2) * json_escape(key) * ": " *
            json_value(value[key], indent + 2) for key in ordered]
        return "{\n" * join(fields, ",\n") * "\n" * repeat(" ", indent) * "}"
    end
    if value isa AbstractVector
        isempty(value) && return "[]"
        fields = [repeat(" ", indent + 2) * json_value(item, indent + 2) for item in value]
        return "[\n" * join(fields, ",\n") * "\n" * repeat(" ", indent) * "]"
    end
    error("unsupported JSON value: $(typeof(value))")
end

function write_json(path, value)
    mkpath(dirname(path))
    open(path, "w") do stream
        println(stream, json_value(value))
    end
end

function write_canonical_csv(path, data, table=nothing)
    names = ["time", "ref_x", "ref_y", "ref_z", "pos_x", "pos_y", "pos_z",
        "att_roll", "att_pitch", "att_yaw", "omega_x", "omega_y", "omega_z",
        ["motor_command_$index" for index in 1:4]...,
        "tracking_error_norm", "yawless_tilt_rad"]
    columns = Any[data.time, data.reference[:, 1], data.reference[:, 2], data.reference[:, 3],
        data.position[:, 1], data.position[:, 2], data.position[:, 3],
        data.attitude[:, 1], data.attitude[:, 2], data.attitude[:, 3],
        data.rates[:, 1], data.rates[:, 2], data.rates[:, 3]]
    if data.rotation !== nothing
        insertion = 14
        for row in 1:3, column in 1:3
            insert!(names, insertion, "rotation_r$(row)$(column)")
            insert!(columns, insertion, data.rotation[:, 3 * (row - 1) + column])
            insertion += 1
        end
    end
    append!(columns, [data.command[:, index] for index in 1:4])
    if data.applied !== nothing
        insert_at = length(names) - 1
        for index in 1:4
            insert!(names, insert_at + index - 1, "motor_applied_$index")
        end
        append!(columns, [data.applied[:, index] for index in 1:4])
    end
    append!(columns, [data.error, data.tilt])
    if table !== nothing
        preserved = filter(table.names) do name
            startswith(name, "controllerDiagnostics[") ||
                startswith(name, "scenarioDiagnostics[") ||
                startswith(name, "disturbanceForce[") ||
                startswith(name, "windVelocity[") ||
                startswith(name, "sensorNoise[") ||
                startswith(name, "allocatorLimit[") ||
                startswith(name, "thrustScale") ||
                (startswith(name, "referenceVector[") &&
                    something(tryparse(Int, match(r"\[(\d+)\]", name).captures[1]), 0) > 3)
        end
        append!(names, preserved)
        append!(columns, [table.columns[name] for name in preserved])
    end
    mkpath(dirname(path))
    open(path, "w") do stream
        println(stream, join(names, ','))
        for row in eachindex(data.time)
            println(stream, join([string(column[row]) for column in columns], ','))
        end
    end
end

function write_outputs(result, output_root, stem)
    paths = Dict(
        "canonical_csv" => joinpath(output_root, "canonical", stem * "_canonical.csv"),
        "metrics_csv" => joinpath(output_root, "metrics", stem * "_metrics.csv"),
        "metrics_json" => joinpath(output_root, "metrics", stem * "_metrics.json"),
        "hard_gates_csv" => joinpath(output_root, "hard_gates", stem * "_hard_gates.csv"),
        "hard_gates_json" => joinpath(output_root, "hard_gates", stem * "_hard_gates.json"))
    write_canonical_csv(paths["canonical_csv"], result.data, result.table)
    write_row_csv(paths["metrics_csv"], result.metrics)
    write_json(paths["metrics_json"], result.metrics)
    write_row_csv(paths["hard_gates_csv"], result.gates)
    write_json(paths["hard_gates_json"], result.gates)
    return paths
end

end
