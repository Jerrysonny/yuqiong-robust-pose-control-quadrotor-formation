module TransientMetricsV7

using Statistics

include(joinpath(@__DIR__, "CanonicalMetricsV7.jl"))
using .CanonicalMetricsV7

export evaluate_standard_step, evaluate_uncertainty_pair, evaluate_disturbance_recovery

function crossing_time(time, values, threshold, direction, first_row, last_row)
    for row in max(first_row + 1, 2):last_row
        before = direction * (values[row - 1] - threshold)
        after = direction * (values[row] - threshold)
        if before < 0.0 && after >= 0.0
            slope = values[row] - values[row - 1]
            abs(slope) <= eps(Float64) && return time[row]
            fraction = clamp((threshold - values[row - 1]) / slope, 0.0, 1.0)
            return time[row - 1] + fraction * (time[row] - time[row - 1])
        end
    end
    return nothing
end

function sustained_entry(time, error, start_row, band, hold_s; limit_row=length(time))
    # 只有误差连续保持在带内达到指定时长，才判定恢复或调节完成。
    for row in start_row:limit_row
        time[row] + hold_s > time[limit_row] + 1e-12 && break
        last_row = min(limit_row, searchsortedlast(time, time[row] + hold_s + 1e-12))
        all(error[row:last_row] .<= band) && return time[row]
    end
    return nothing
end

function standard_step_contract(data, axis; step_time=10.0, hold_s=2.0,
        relative_band=0.02, absolute_band=0.02, steady_fraction=0.20)
    axis in 1:3 || error("axis must be 1, 2, or 3")
    pre_row = searchsortedlast(data.time, step_time - 1e-12)
    start_row = searchsortedfirst(data.time, step_time)
    pre_row >= 1 || error("standard step has no pre-step sample")
    start_row <= length(data.time) || error("standard step time is outside the result")
    initial = data.reference[pre_row, axis]
    target = data.reference[start_row, axis]
    delta = target - initial
    abs(delta) > 1e-9 || error("selected axis has no step at t=$step_time")
    direction = sign(delta)
    response = data.position[:, axis]
    time10 = crossing_time(data.time, response, initial + 0.1 * delta,
        direction, start_row, length(data.time))
    time90 = crossing_time(data.time, response, initial + 0.9 * delta,
        direction, start_row, length(data.time))
    rise = time10 === nothing || time90 === nothing ? nothing : time90 - time10
    overshoot = max(0.0, maximum(direction .* (response[start_row:end] .- target)))
    band = max(relative_band * abs(delta), absolute_band)
    axis_error = abs.(target .- response)
    settled_at = sustained_entry(data.time, axis_error, start_row, band, hold_s)
    settling = settled_at === nothing ? nothing : settled_at - step_time
    post_count = length(data.time) - start_row + 1
    steady_count = max(1, floor(Int, steady_fraction * post_count))
    steady_start = length(data.time) - steady_count + 1
    signed = target .- response[steady_start:end]
    return Dict{String,Any}(
        "step_axis" => axis,
        "step_amplitude_m" => abs(delta),
        "rise_time_10_90_s" => rise,
        "rise_status" => rise === nothing ? "not_reached" : "reached",
        "overshoot_m" => overshoot,
        "overshoot_percent" => 100.0 * overshoot / abs(delta),
        "settling_band_m" => band,
        "settling_time_s" => settling,
        "settling_status" => settling === nothing ? "not_settled" : "settled",
        "steady_signed_error_m" => mean(signed),
        "steady_abs_error_m" => mean(abs, signed),
        "steady_rmse_m" => sqrt(mean(abs2, signed)))
end

function evaluate_standard_step(path; axis, config_path, q_max=nothing)
    # 标准阶跃统一计算上升、超调、调节和稳态误差。
    scene = ("Scene01S_X", "Scene01S_Y", "Scene01S_Z")[axis]
    result = evaluate_file(path; scene=scene, config_path=config_path,
        expected_stop=30.0, q_max=q_max)
    step = standard_step_contract(result.data, axis)
    metrics = merge(copy(result.metrics), step)
    gates = copy(result.gates)
    gates["rise_reached"] = step["rise_status"] == "reached"
    gates["overshoot_percent_le_10"] = step["overshoot_percent"] <= 10.0
    gates["settled_before_end"] = step["settling_status"] == "settled"
    gates["steady_abs_error_le_0_02_m"] = step["steady_abs_error_m"] <= 0.02
    gates["all_pass"] = all(value for (key, value) in gates if key != "scene" && value isa Bool)
    return (; table=result.table, data=result.data, metrics, gates)
end

function trajectory_transient_contract(data; hold_s=2.0,
        relative_band=0.02, absolute_band=0.02, steady_fraction=0.20)
    motion = vec(sqrt.(sum(abs2, diff(data.reference; dims=1); dims=2))) .> 1e-9
    last_edge = findlast(motion)
    last_edge === nothing && error("trajectory has no reference motion")
    start_row = last_edge + 1
    initial, target = data.reference[1, :], data.reference[end, :]
    delta = target - initial
    axis = argmax(abs.(delta))
    amplitude = abs(delta[axis])
    amplitude > 1e-9 || error("trajectory has no nonzero command amplitude")
    direction = sign(delta[axis])
    response = data.position[:, axis]
    overshoot = max(0.0, maximum(direction .* (response[start_row:end] .- target[axis])))
    band = max(relative_band * amplitude, absolute_band)
    settled_at = sustained_entry(data.time, abs.(target[axis] .- response), start_row, band, hold_s)
    settling = settled_at === nothing ? nothing : settled_at - data.time[start_row]
    steady_count = max(1, floor(Int, steady_fraction * (length(data.time) - start_row + 1)))
    signed = target[axis] .- response[end - steady_count + 1:end]
    return Dict{String,Any}(
        "transient_axis" => axis, "transient_motion_end_s" => data.time[start_row],
        "transient_command_amplitude_m" => amplitude,
        "transient_overshoot_m" => overshoot,
        "transient_overshoot_percent" => 100.0 * overshoot / amplitude,
        "transient_settling_time_s" => settling,
        "transient_settling_status" => settling === nothing ? "not_settled" : "settled",
        "transient_steady_signed_error_m" => mean(signed),
        "transient_steady_abs_error_m" => mean(abs, signed))
end

function thrust_estimator_contract(table, time)
    scale = find_series(table, ["controllerDiagnostics[11]", "thrustScale",
        "thrust_scale"]; required=false)
    valid = scale !== nothing && all(isfinite, scale) && all(0.75 .<= scale .<= 1.35)
    !valid && return Dict{String,Any}(
        "thrust_estimator_evidence" => false, "thrust_scale_final" => nothing,
        "thrust_scale_update_fraction" => nothing, "thrust_scale_convergence_time_s" => nothing,
        "thrust_scale_convergence_status" => "not_available",
        "thrust_scale_boundary_touched" => nothing)
    final_value = scale[end]
    band = max(0.01, 0.02 * abs(final_value - 1.0))
    violating = findall(abs.(scale .- final_value) .> band)
    convergence_row = isempty(violating) ? 1 : violating[end] < length(scale) ? violating[end] + 1 : nothing
    update_fraction = length(scale) <= 1 ? 0.0 : mean(abs.(diff(scale)) .> 1e-12)
    return Dict{String,Any}(
        "thrust_estimator_evidence" => true, "thrust_scale_final" => final_value,
        "thrust_scale_update_fraction" => update_fraction, "thrust_scale_convergence_band" => band,
        "thrust_scale_convergence_time_s" => convergence_row === nothing ? nothing : time[convergence_row] - time[1],
        "thrust_scale_convergence_status" => convergence_row === nothing ? "not_converged" : "converged",
        "thrust_scale_boundary_touched" => any(scale .<= 0.7500001) || any(scale .>= 1.3499999))
end

function retention_ratio(numerator, denominator)
    denominator > 1e-12 && return (numerator / denominator, "evaluated")
    numerator <= 1e-12 && return (1.0, "both_zero")
    return (nothing, "not_evaluable_nominal_zero")
end

function evaluate_uncertainty_pair(perturbed_path, nominal_path, pid_path;
    # 参数摄动必须与名义和PID结果按同一合同成组比较。
        config_path, q_max=nothing)
    perturbed = evaluate_file(perturbed_path; scene="Scene05B", config_path=config_path,
        expected_stop=50.0, q_max=q_max)
    nominal = evaluate_file(nominal_path; scene="Scene05B", config_path=config_path,
        expected_stop=50.0, q_max=q_max)
    pid = evaluate_file(pid_path; scene="Scene05B", config_path=config_path,
        expected_stop=50.0, q_max=q_max)
    ratio_nominal = perturbed.metrics["tracking_rmse_m"] / nominal.metrics["tracking_rmse_m"]
    ratio_pid = perturbed.metrics["tracking_rmse_m"] / pid.metrics["tracking_rmse_m"]
    perturbed_transient = trajectory_transient_contract(perturbed.data)
    nominal_transient = trajectory_transient_contract(nominal.data)
    perturbed_settling = perturbed_transient["transient_settling_time_s"]
    nominal_settling = nominal_transient["transient_settling_time_s"]
    settling_retention = perturbed_settling === nothing || nominal_settling === nothing ? nothing :
        nominal_settling <= 1e-12 ? (perturbed_settling <= 1e-12 ? 1.0 : nothing) :
        perturbed_settling / nominal_settling
    variation_retention, variation_status = retention_ratio(
        perturbed.metrics["motor_total_variation"], nominal.metrics["motor_total_variation"])
    estimator = thrust_estimator_contract(perturbed.table, perturbed.data.time)
    final_start = max(1, floor(Int, 0.8 * length(perturbed.data.time)))
    final_error = perturbed.data.reference[final_start:end, 3] .-
        perturbed.data.position[final_start:end, 3]
    metrics = merge(copy(perturbed.metrics), perturbed_transient, estimator, Dict{String,Any}(
        "paired_nominal_rmse_m" => nominal.metrics["tracking_rmse_m"],
        "pid_rmse_m" => pid.metrics["tracking_rmse_m"],
        "rmse_retention_ratio" => ratio_nominal,
        "rmse_ratio_vs_pid" => ratio_pid,
        "paired_nominal_settling_time_s" => nominal_settling,
        "settling_time_retention_ratio" => settling_retention,
        "overshoot_increment_percent" => perturbed_transient["transient_overshoot_percent"] -
            nominal_transient["transient_overshoot_percent"],
        "steady_abs_error_increment_m" => perturbed_transient["transient_steady_abs_error_m"] -
            nominal_transient["transient_steady_abs_error_m"],
        "motor_total_variation_retention_ratio" => variation_retention,
        "motor_total_variation_retention_status" => variation_status,
        "steady_signed_error_m" => mean(final_error),
        "steady_abs_error_m" => mean(abs, final_error)))
    gates = copy(perturbed.gates)
    gates["tracking_peak_le_0_50_m"] = perturbed.metrics["tracking_peak_m"] <= 0.50
    gates["steady_abs_error_le_0_05_m"] = metrics["steady_abs_error_m"] <= 0.05
    gates["rmse_retention_le_2"] = ratio_nominal <= 2.0
    gates["settled_under_perturbation"] = perturbed_settling !== nothing
    gates["all_pass"] = all(value for (key, value) in gates if key != "scene" && value isa Bool)
    return (; table=perturbed.table, data=perturbed.data, metrics, gates)
end

function active_segments(active)
    segments = Tuple{Int,Int}[]
    row = 1
    while row <= length(active)
        if active[row]
            first_row = row
            while row < length(active) && active[row + 1]
                row += 1
            end
            push!(segments, (first_row, row))
        end
        row += 1
    end
    return segments
end

function evaluate_disturbance_recovery(path; config_path, q_max=nothing)
    # 每次外扰独立计算峰值和持续恢复时间，保留最差事件。
    result = evaluate_file(path; scene="Scene06b", config_path=config_path,
        expected_stop=30.0, q_max=q_max)
    forces = [find_series(result.table, ["disturbanceForce[$axis]",
        "disturbance_force_$axis", "scenarioDiagnostics[$axis]"]; required=false) for axis in 1:3]
    all(force -> force !== nothing, forces) || error("Scene06b missing three-axis disturbance evidence")
    force_norm = vec(sqrt.(sum(abs2, hcat(forces...); dims=2)))
    segments = active_segments(force_norm .> 1e-12)
    isempty(segments) && error("Scene06b contains no active disturbance event")
    recovery, pre_rmse, event_rmse = Float64[], Float64[], Float64[]
    for (event, (first_row, last_row)) in enumerate(segments)
        pre_start = searchsortedfirst(result.data.time,
            max(result.data.time[1], result.data.time[first_row] - 1.0))
        baseline = sqrt(mean(abs2,
            result.data.error[pre_start:max(pre_start, first_row - 1)]))
        threshold = max(0.05, 1.25 * baseline)
        limit_row = event < length(segments) ? segments[event + 1][1] - 1 : length(result.data.time)
        recovered_at = sustained_entry(result.data.time, result.data.error,
            last_row, threshold, 1.0; limit_row=limit_row)
        push!(recovery, recovered_at === nothing ? Inf : recovered_at - result.data.time[last_row])
        push!(pre_rmse, baseline)
        push!(event_rmse, sqrt(mean(abs2, result.data.error[first_row:last_row])))
    end
    metrics = merge(copy(result.metrics), Dict{String,Any}(
        "disturbance_event_count" => length(segments),
        "disturbance_force_peak_n" => maximum(force_norm),
        "disturbance_pre_rmse_max_m" => maximum(pre_rmse),
        "disturbance_event_rmse_max_m" => maximum(event_rmse),
        "disturbance_recovery_time_max_s" => maximum(recovery),
        "evidence_has_disturbance_vector" => true))
    gates = copy(result.gates)
    gates["required_disturbance_vector_evidence"] = true
    gates["disturbance_recovery_le_5_s"] = all(isfinite, recovery) && maximum(recovery) <= 5.0
    gates["all_pass"] = all(value for (key, value) in gates if key != "scene" && value isa Bool)
    return (; table=result.table, data=result.data, metrics, gates)
end

end
