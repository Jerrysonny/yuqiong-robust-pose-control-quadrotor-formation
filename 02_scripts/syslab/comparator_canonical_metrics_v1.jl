module CanonicalMetricsV1

using DelimitedFiles
using Statistics
using TOML
using Printf

export REQUIRED_COLUMNS, load_config, read_canonical, resample_canonical,
       evaluate_scenario, evaluate_bundle, aggregate_from_metrics,
       score_bundles, normalized_loss, write_metrics_csv

const REQUIRED_COLUMNS = [
    "time",
    "ref_x", "ref_y", "ref_z",
    "pos_x", "pos_y", "pos_z",
    "att_roll", "att_pitch", "att_yaw",
    "omega_x", "omega_y", "omega_z",
    "motor_1", "motor_2", "motor_3", "motor_4",
    "allocation_residual_norm", "clipping_flag", "disturbance_active",
]

struct CanonicalTable
    names::Vector{String}
    values::Matrix{Float64}
    index::Dict{String,Int}
end

load_config(path::AbstractString) = TOML.parsefile(path)

function require_keys(d::AbstractDict, keys, label::AbstractString)
    missing = [string(k) for k in keys if !haskey(d, k)]
    isempty(missing) || error("$label missing keys: " * join(missing, ","))
end

function read_canonical(path::AbstractString)
    # 缺失列、非数字值和非有限值均在读入阶段直接拒绝。
    isfile(path) || error("canonical file missing: $path")
    filesize(path) > 0 || error("canonical file empty: $path")
    firstline = open(readline, path)
    names = replace.(strip.(split(firstline, ',')), '\ufeff' => "")
    all(!isempty, names) || error("empty header")
    length(unique(names)) == length(names) || error("duplicate headers")
    missing = setdiff(REQUIRED_COLUMNS, names)
    isempty(missing) || error("missing required columns: " * join(missing, ","))

    data, parsed_header = readdlm(path, ',', header=true)
    parsed_names = replace.(strip.(vec(String.(parsed_header))), '\ufeff' => "")
    parsed_names == names || error("header parse mismatch")
    size(data, 1) >= 2 || error("canonical file needs at least two rows")
    values = try
        Float64.(data)
    catch err
        error("nonnumeric or NA canonical value: $(sprint(showerror, err))")
    end
    all(isfinite, values) || error("nonfinite canonical value")
    index = Dict(name => i for (i, name) in enumerate(names))
    time = values[:, index["time"]]
    all(diff(time) .> 0) || error("time must be strictly increasing; duplicate/decreasing time rejected")
    clip = values[:, index["clipping_flag"]]
    all((clip .>= 0) .& (clip .<= 1)) || error("clipping_flag outside [0,1]")
    active = values[:, index["disturbance_active"]]
    all((active .>= 0) .& (active .<= 1)) || error("disturbance_active outside [0,1]")
    CanonicalTable(names, values, index)
end

function uniform_grid(start_time::Real, stop_time::Real, dt::Real)
    stop_time > start_time || error("zero-length scene window")
    dt > 0 || error("grid dt must be positive")
    intervals = round(Int, (stop_time - start_time) / dt)
    isapprox(start_time + intervals * dt, stop_time; atol=1e-10, rtol=0) ||
        error("scene duration is not divisible by grid dt")
    collect(range(Float64(start_time), step=Float64(dt), length=intervals + 1))
end

function linear_sample(t::Vector{Float64}, y::Vector{Float64}, grid::Vector{Float64})
    out = similar(grid)
    for (k, x) in enumerate(grid)
        j = searchsortedlast(t, x)
        if j == 0
            error("resampling requested before raw start")
        elseif j >= length(t)
            out[k] = y[end]
        elseif isapprox(x, t[j]; atol=1e-12, rtol=0)
            out[k] = y[j]
        else
            alpha = (x - t[j]) / (t[j + 1] - t[j])
            out[k] = muladd(alpha, y[j + 1] - y[j], y[j])
        end
    end
    out
end

function zoh_sample(t::Vector{Float64}, y::Vector{Float64}, grid::Vector{Float64})
    [y[max(1, searchsortedlast(t, x))] for x in grid]
end

function resample_canonical(table::CanonicalTable, scene_spec::AbstractDict, grid_spec::AbstractDict)
    # 连续量线性插值，离散标志量使用零阶保持。
    start_time = Float64(scene_spec["start"])
    stop_time = Float64(scene_spec["stop"])
    dt = Float64(grid_spec["dt"])
    tol = Float64(grid_spec["time_tolerance"])
    max_gap = Float64(grid_spec["max_raw_gap"])
    time = table.values[:, table.index["time"]]
    time[1] <= start_time + tol || error("raw starts after required scene start")
    time[end] >= stop_time - tol || error("truncated time axis")
    maximum(diff(time)) <= max_gap + tol || error("raw time gap exceeds max_raw_gap")
    grid = uniform_grid(start_time, stop_time, dt)
    values = Matrix{Float64}(undef, length(grid), length(table.names))
    discrete = Set(["clipping_flag", "disturbance_active"])
    for (j, name) in enumerate(table.names)
        if name == "time"
            values[:, j] = grid
        elseif name in discrete
            values[:, j] = zoh_sample(time, table.values[:, j], grid)
        else
            values[:, j] = linear_sample(time, table.values[:, j], grid)
        end
    end
    CanonicalTable(table.names, values, table.index)
end

col(table::CanonicalTable, name::AbstractString) = table.values[:, table.index[String(name)]]

function recovery_time(time, error_norm, final_end, threshold, hold)
    # 恢复时间要求误差进入阈值后持续保持指定时长。
    dt = time[2] - time[1]
    needed = max(1, ceil(Int, hold / dt)) + 1
    first_index = searchsortedfirst(time, final_end)
    for i in first_index:(length(time) - needed + 1)
        if all(error_norm[i:(i + needed - 1)] .<= threshold)
            return time[i] - final_end
        end
    end
    Inf
end

function evaluate_scenario(path::AbstractString, scene_id::AbstractString, config::AbstractDict)
    scenes = config["scenes"]
    haskey(scenes, scene_id) || error("unknown scene: $scene_id")
    table = resample_canonical(read_canonical(path), scenes[scene_id], config["grid"])
    time = col(table, "time")
    ref = hcat((col(table, "ref_$axis") for axis in ("x", "y", "z"))...)
    pos = hcat((col(table, "pos_$axis") for axis in ("x", "y", "z"))...)
    att = hcat((col(table, "att_$axis") for axis in ("roll", "pitch", "yaw"))...)
    omega = hcat((col(table, "omega_$axis") for axis in ("x", "y", "z"))...)
    motors = hcat((col(table, "motor_$i") for i in 1:4)...)
    err = pos - ref
    err_norm = sqrt.(vec(sum(abs2, err; dims=2)))
    dt = diff(time)
    metrics = Dict{String,Float64}(
        "tracking_rmse3" => sqrt(mean(sum(abs2, err; dims=2))),
        "tracking_max3" => maximum(err_norm),
        "tracking_iae3" => sum((err_norm[1:end-1] .+ err_norm[2:end]) .* dt ./ 2),
        "attitude_max" => maximum(sqrt.(vec(sum(abs2, att; dims=2)))),
        "body_rate_rms" => sqrt(mean(sum(abs2, omega; dims=2))),
        "motor_rms" => sqrt(mean(abs2, motors)),
        "motor_rate_rms" => sqrt(mean(abs2, diff(motors; dims=1) ./ dt)),
        "clipping_rate" => mean(col(table, "clipping_flag")),
        "allocation_residual_rms" => sqrt(mean(abs2, col(table, "allocation_residual_norm"))),
    )
    if scene_id == "scene_06b_multi_disturbance"
        spec = scenes[scene_id]
        start_index = searchsortedfirst(time, Float64(spec["disturbance_start"]))
        disturbance_error = err_norm[start_index:end]
        metrics["disturbance_rmse3"] = sqrt(mean(abs2, disturbance_error))
        metrics["disturbance_max3"] = maximum(disturbance_error)
        metrics["disturbance_recovery_time"] = recovery_time(
            time, err_norm, Float64(spec["final_pulse_end"]),
            Float64(spec["recovery_threshold"]), Float64(spec["recovery_hold"]))
    end
    for (name, value) in metrics
        value >= 0 || error("negative metric: $name")
        (isfinite(value) || name == "disturbance_recovery_time") || error("nonfinite metric: $name")
    end
    metrics
end

function evaluate_bundle(files::AbstractDict, status::AbstractDict, config::AbstractDict)
    required = String.(config["required_scenes"])
    metrics = Dict{String,Dict{String,Float64}}()
    for scene in required
        haskey(files, scene) || error("missing required scene: $scene")
        get(status, scene, false) === true || error("simulation failed or unverified: $scene")
        metrics[scene] = evaluate_scenario(files[scene], scene, config)
    end
    metrics
end

function normalized_loss(algorithm::Real, pid::Real, epsilon::Real)
    # 零基线和非有限值采用显式规则，避免静默产生无效比值。
    epsilon > 0 || error("epsilon must be positive")
    (isnan(algorithm) || isnan(pid) || algorithm < 0 || pid < 0) && return Inf
    if isinf(pid)
        return isinf(algorithm) ? 1.0 : 0.0
    elseif isinf(algorithm)
        return Inf
    elseif pid <= epsilon
        return algorithm <= epsilon ? 1.0 : Inf
    end
    Float64(algorithm / pid)
end

function weighted_average(values::Vector{Float64}, weights::Vector{Float64})
    length(values) == length(weights) || error("weight/value length mismatch")
    isempty(values) && error("empty weighted average")
    all(weight -> weight >= 0 && isfinite(weight), weights) || error("invalid weight")
    weight_sum = sum(weights)
    weight_sum > 0 || error("zero weight sum")
    all(value -> value == values[1], values) && return values[1]
    sum(weights .* values) / weight_sum
end

function weighted_metric_loss(pid_metrics, algorithm_metrics, weights, epsilons)
    losses = Float64[]
    metric_weights = Float64[]
    for (metric, weight) in weights
        haskey(pid_metrics, metric) || error("PID metric missing: $metric")
        haskey(algorithm_metrics, metric) || error("algorithm metric missing: $metric")
        haskey(epsilons, metric) || error("epsilon missing: $metric")
        push!(losses, normalized_loss(
            algorithm_metrics[metric], pid_metrics[metric], Float64(epsilons[metric])))
        push!(metric_weights, Float64(weight))
    end
    weighted_average(losses, metric_weights)
end

function aggregate_from_metrics(pid, algorithm, config::AbstractDict)
    # 公共场景按指标权重和场景权重汇总为单一损失。
    required = String.(config["required_scenes"])
    all(haskey(pid, s) && haskey(algorithm, s) for s in required) || error("missing scenario metrics")
    epsilons = config["epsilons"]

    tracking_scene_losses = Float64[]
    tracking_scene_weights = Float64[]
    for scene in String.(config["tracking_scenes"])
        push!(tracking_scene_losses, weighted_metric_loss(pid[scene], algorithm[scene],
            config["tracking_metric_weights"], epsilons))
        push!(tracking_scene_weights, Float64(config["tracking_scene_weights"][scene]))
    end
    tracking = weighted_average(tracking_scene_losses, tracking_scene_weights)

    robustness = weighted_metric_loss(
        pid["scene_06b_multi_disturbance"], algorithm["scene_06b_multi_disturbance"],
        config["robustness_metric_weights"], epsilons)

    control_scenes = String.(config["control_cost_scenes"])
    durations = Dict(scene => Float64(config["scenes"][scene]["stop"] - config["scenes"][scene]["start"])
        for scene in control_scenes)
    duration_sum = sum(values(durations))
    control_losses = [weighted_metric_loss(pid[scene], algorithm[scene],
        config["control_metric_weights"], epsilons) for scene in control_scenes]
    control = weighted_average(control_losses, [durations[scene] / duration_sum for scene in control_scenes])

    weights = config["aggregate_weights"]
    total = weighted_average([tracking, robustness, control],
        Float64.([weights["tracking"], weights["robustness"], weights["control_cost"]]))
    (tracking_loss=tracking, robustness_loss=robustness,
        control_cost_loss=control, total_loss=total)
end

function score_bundles(pid_files, algorithm_files, config_path::AbstractString;
        pid_status=Dict{String,Bool}(), algorithm_status=Dict{String,Bool}())
    config = load_config(config_path)
    try
        pid = evaluate_bundle(pid_files, pid_status, config)
        algorithm = evaluate_bundle(algorithm_files, algorithm_status, config)
        losses = aggregate_from_metrics(pid, algorithm, config)
        return merge((status="pass", reason=""), losses)
    catch err
        return (status="fail", reason=sprint(showerror, err), tracking_loss=Inf,
            robustness_loss=Inf, control_cost_loss=Inf, total_loss=Inf)
    end
end

function write_metrics_csv(path::AbstractString, metrics)
    mkpath(dirname(path))
    open(path, "w") do io
        println(io, "scene,metric,value")
        for scene in sort(collect(keys(metrics)))
            for metric in sort(collect(keys(metrics[scene])))
                @printf(io, "%s,%s,%.17g\n", scene, metric, metrics[scene][metric])
            end
        end
    end
    path
end

end
