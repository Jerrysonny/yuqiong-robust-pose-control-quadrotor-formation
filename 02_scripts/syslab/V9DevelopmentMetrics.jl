module V9DevelopmentMetrics

using LinearAlgebra
using Statistics

export NumericTable, read_numeric_csv, evaluate_tracking, evaluate_v9,
    evaluate_step, write_csv, write_json, json_value

struct NumericTable
    names::Vector{String}
    columns::Dict{String,Vector{Float64}}
end

function split_csv_line(line::AbstractString)
    fields = String[]
    buffer = IOBuffer()
    quoted = false
    index = firstindex(line)
    while index <= lastindex(line)
        character = line[index]
        if character == '"'
            next_index = nextind(line, index)
            if quoted && next_index <= lastindex(line) && line[next_index] == '"'
                write(buffer, '"')
                index = next_index
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
    push!(fields, String(take!(buffer)))
    return fields
end

function read_numeric_csv(path::AbstractString)
    isfile(path) || error("missing CSV: $path")
    open(path, "r") do stream
        eof(stream) && error("empty CSV: $path")
        names = split_csv_line(chomp(readline(stream)))
        length(unique(names)) == length(names) || error("duplicate CSV columns: $path")
        columns = Dict(name => Float64[] for name in names)
        row_count = 0
        for line in eachline(stream)
            isempty(strip(line)) && continue
            fields = split_csv_line(line)
            length(fields) == length(names) || error(
                "CSV width mismatch at row $(row_count + 2)")
            for (name, field) in zip(names, fields)
                value = tryparse(Float64, strip(field))
                value === nothing && error(
                    "non-numeric value in $name at row $(row_count + 2)")
                push!(columns[name], value)
            end
            row_count += 1
        end
        row_count > 1 || error("insufficient CSV rows: $path")
        return NumericTable(names, columns)
    end
end

series(table::NumericTable, name::AbstractString) = haskey(table.columns, name) ?
    table.columns[name] : error("missing required series: $name")

time_series(table::NumericTable) = haskey(table.columns, "time") ?
    table.columns["time"] : haskey(table.columns, "Time") ?
    table.columns["Time"] : error("missing required time series: expected time or Time")

function tracking_metrics(table::NumericTable; steady_fraction=0.20)
    reference = hcat([series(table, "referenceVector[$axis]") for axis in 1:3]...)
    position = hcat([series(table,
        "quadChassisTest17_1.body.r_0[$axis]") for axis in 1:3]...)
    error = reference - position
    error_norm = sqrt.(vec(sum(abs2, error; dims=2)))
    first_steady = max(1, floor(Int, (1.0 - steady_fraction) * length(error_norm)) + 1)
    steady_signed = vec(mean(@view(error[first_steady:end, :]); dims=1))
    return Dict{String,Any}(
        "tracking_rmse_m" => sqrt(mean(abs2, error_norm)),
        "tracking_peak_m" => maximum(error_norm),
        "steady_abs_error_m" => norm(steady_signed),
        "steady_rmse_m" => sqrt(mean(abs2, @view error_norm[first_steady:end])))
end

function time_gates(table::NumericTable, expected_stop)
    time = time_series(table)
    expected_rows = round(Int, expected_stop / 0.01) + 1
    return Dict{String,Any}(
        "finite_values" => all(values -> all(isfinite, values), values(table.columns)),
        "expected_rows" => length(time) == expected_rows,
        "expected_start" => abs(first(time)) <= 1.0e-12,
        "expected_stop" => abs(last(time) - expected_stop) <= 1.0e-8,
        "strict_time" => all(diff(time) .> 0.0))
end

function evaluate_tracking(path::AbstractString; expected_stop)
    table = read_numeric_csv(path)
    metrics = tracking_metrics(table)
    gates = time_gates(table, expected_stop)
    gates["all_pass"] = all(value === true for value in values(gates))
    return (; table, metrics, gates)
end

function rotation_metrics(table::NumericTable)
    names = ["quadChassisTest17_1.body.frame_b.R.T[$row,$column]"
        for row in 1:3 for column in 1:3]
    row_count = length(series(table, names[1]))
    orthogonality = 0.0
    determinant = 0.0
    tilt = 0.0
    for index in 1:row_count
        rotation = [series(table,
            "quadChassisTest17_1.body.frame_b.R.T[$row,$column]")[index]
            for row in 1:3, column in 1:3]
        orthogonality = max(orthogonality, norm(transpose(rotation) * rotation - I))
        determinant = max(determinant, abs(det(rotation) - 1.0))
        tilt = max(tilt, acos(clamp(rotation[3, 3], -1.0, 1.0)))
    end
    return Dict{String,Any}(
        "max_rotation_orthogonality_error" => orthogonality,
        "max_rotation_determinant_error" => determinant,
        "max_yawless_tilt_rad" => tilt)
end

function evaluate_v9(path::AbstractString; expected_stop, target_scale=nothing)
    tracking = evaluate_tracking(path; expected_stop=expected_stop)
    table = tracking.table
    metrics = copy(tracking.metrics)
    merge!(metrics, rotation_metrics(table))
    body_rate = maximum(abs(value) for axis in 1:3 for value in
        series(table, "quadChassisTest17_1.body.frame_b.R.w[$axis]"))
    command_q = maximum(abs2(value) for motor in 1:4 for value in
        series(table, "motorCommand[$motor]"))
    applied_q = maximum(abs2(value) for motor in 1:4 for value in
        series(table, "speedSensor[$motor].w"))
    q_limit = series(table, "controllerDiagnostics[15]")
    scale_hat = series(table, "controllerDiagnostics[11]")
    scale_apply = series(table, "controllerDiagnostics[12]")
    fusion_valid = series(table, "controllerDiagnostics[13]")
    innovation = series(table, "controllerDiagnostics[14]")
    version = series(table, "controllerDiagnostics[16]")
    terminal_start = max(1, length(scale_apply) - 99)
    scale_hat_terminal = mean(@view scale_hat[terminal_start:end])
    scale_apply_terminal = mean(@view scale_apply[terminal_start:end])
    merge!(metrics, Dict{String,Any}(
        "max_abs_body_rate_radps" => body_rate,
        "max_motor_command_q" => command_q,
        "max_motor_applied_q" => applied_q,
        "allocator_q_limit_min" => minimum(q_limit),
        "allocator_q_limit_max" => maximum(q_limit),
        "scale_hat_min" => minimum(scale_hat),
        "scale_hat_max" => maximum(scale_hat),
        "scale_apply_min" => minimum(scale_apply),
        "scale_apply_max" => maximum(scale_apply),
        "scale_apply_max_deviation_from_one" => maximum(abs.(scale_apply .- 1.0)),
        "scale_hat_terminal" => scale_hat_terminal,
        "scale_apply_terminal" => scale_apply_terminal,
        "scale_apply_terminal_relative_error" => target_scale === nothing ? nothing :
            abs(scale_apply_terminal - target_scale) / abs(target_scale),
        "fusion_valid_fraction" => count(value -> value >= 0.5, fusion_valid) /
            length(fusion_valid),
        "normalized_innovation_abs_max" => maximum(abs, innovation),
        "version_min" => minimum(version),
        "version_max" => maximum(version)))
    gates = copy(tracking.gates)
    merge!(gates, Dict{String,Any}(
        "rotation_orthogonality" =>
            metrics["max_rotation_orthogonality_error"] <= 1.0e-6,
        "rotation_determinant" =>
            metrics["max_rotation_determinant_error"] <= 1.0e-6,
        "yawless_tilt" => metrics["max_yawless_tilt_rad"] <= 1.20,
        "body_rate" => body_rate <= 20.0,
        "motor_command_limit" => command_q <= maximum(q_limit) + 1.0e-8,
        "motor_applied_limit" => applied_q <= maximum(q_limit) + 1.0e-8,
        "scale_hat_projection" => minimum(scale_hat) >= 0.75 - 1.0e-12 &&
            maximum(scale_hat) <= 1.35 + 1.0e-12,
        "scale_apply_projection" => minimum(scale_apply) >= 0.75 - 1.0e-12 &&
            maximum(scale_apply) <= 1.35 + 1.0e-12,
        "fusion_flag_binary" => all(value -> value == 0.0 || value == 1.0,
            fusion_valid),
        "version_code" => minimum(version) == 901.0 && maximum(version) == 901.0))
    gates["all_physical_pass"] = all(value === true for (key, value) in gates
        if key != "all_pass")
    return (; table, metrics, gates)
end

function evaluate_step(run, axis::Int, target::Float64; step_time=10.0,
        amplitude=1.0, band=0.02)
    time = time_series(run.table)
    position = series(run.table, "quadChassisTest17_1.body.r_0[$axis]")
    first_step = findfirst(value -> value >= step_time, time)
    first_step === nothing && error("step time is outside result")
    after = first_step:length(time)
    overshoot = max(0.0, (maximum(@view position[after]) - target) /
        amplitude * 100.0)
    tail_start = max(first_step, floor(Int, 0.80 * length(time)) + 1)
    steady_abs_error = mean(abs.((@view position[tail_start:end]) .- target))
    settling_time = nothing
    for index in after
        if all(abs.((@view position[index:end]) .- target) .<= band)
            settling_time = time[index] - step_time
            break
        end
    end
    return Dict{String,Any}(
        "step_axis" => axis,
        "step_target_m" => target,
        "step_overshoot_percent" => overshoot,
        "step_steady_abs_error_m" => steady_abs_error,
        "step_settling_time_s" => settling_time)
end

function json_value(value)
    value === nothing && return "null"
    value isa Bool && return value ? "true" : "false"
    value isa Number && return isfinite(value) ? string(value) : "null"
    value isa AbstractString && return "\"" * replace(value,
        "\\" => "\\\\", "\"" => "\\\"", "\n" => "\\n") * "\""
    value isa AbstractVector && return "[" * join(json_value.(value), ",") * "]"
    value isa AbstractDict && return "{" * join([json_value(string(key)) * ":" *
        json_value(value[key]) for key in sort(collect(keys(value)); by=string)], ",") * "}"
    return json_value(string(value))
end

function write_json(path::AbstractString, value)
    mkpath(dirname(path))
    open(path, "w") do stream
        println(stream, json_value(value))
    end
end

csv_escape(value) = value === nothing ? "" : begin
    text = string(value)
    occursin(r"[,\"\n]", text) ? "\"" * replace(text, "\"" => "\"\"") * "\"" : text
end

function write_csv(path::AbstractString, columns, rows)
    mkpath(dirname(path))
    open(path, "w") do stream
        println(stream, join(csv_escape.(columns), ','))
        for row in rows
            println(stream, join([csv_escape(get(row, column, nothing))
                for column in columns], ','))
        end
    end
end

end
