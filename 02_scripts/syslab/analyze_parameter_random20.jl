using DelimitedFiles
using LinearAlgebra
using Printf
using Random
using SHA
using Statistics

const SAMPLE_COUNT = 20
const BOOTSTRAP_COUNT = 10_000
const BOOTSTRAP_SEED = 2026071901
const TIE_TOLERANCE_M = 1e-12
const WILSON_Z_ONE_SIDED_95 = 1.6448536269514722

function sha256_upper(path::String)
    return uppercase(bytes2hex(open(sha256, path)))
end

function atomic_write(path::String, content::String)
    ispath(path) && error("refusing to overwrite result: $path")
    mkpath(dirname(path))
    temporary = path * ".tmp"
    open(temporary, "w") do stream
        write(stream, content)
    end
    mv(temporary, path)
end

function read_samples(path::String)
    lines = split(chomp(read(path, String)), '\n')
    length(lines) == SAMPLE_COUNT + 1 || error("sample manifest must contain 20 rows")
    header = split(strip(first(lines)), ',')
    expected = [
        "case_id", "lift_scale", "mass_scale", "inertia_scale", "seed",
        "draw_index", "distribution", "formal_statistics_eligible",
    ]
    header == expected || error("unexpected sample manifest header")
    rows = NamedTuple[]
    for (index, line) in enumerate(lines[2:end])
        fields = split(strip(line), ',')
        length(fields) == length(expected) || error("invalid sample row")
        fields[1] == @sprintf("MC20_%02d", index) || error("unexpected sample order")
        parse(Int, fields[5]) == 20260719 || error("unexpected sample seed")
        parse(Int, fields[6]) == index || error("unexpected draw index")
        lowercase(fields[8]) == "true" || error("ineligible sample")
        scales = parse.(Float64, fields[2:4])
        all(value -> 0.90 <= value <= 1.10, scales) || error("sample out of range")
        push!(
            rows,
            (
                case_id=fields[1],
                lift_scale=scales[1],
                mass_scale=scales[2],
                inertia_scale=scales[3],
            ),
        )
    end
    return rows
end

function read_numeric_csv(path::String)
    data, header = readdlm(path, ',', Float64; header=true)
    names = String.(vec(header))
    columns = Dict(name => index for (index, name) in enumerate(names))
    return Matrix{Float64}(data), columns
end

function controller_metrics(path::String)
    data, columns = read_numeric_csv(path)
    required = [
        "time_s",
        "reference_x_m", "reference_y_m", "reference_z_m",
        "position_x_m", "position_y_m", "position_z_m",
    ]
    all(haskey(columns, name) for name in required) || error("missing required columns in $path")
    size(data, 1) == 5001 || error("unexpected row count in $path")
    all(isfinite, data) || error("non-finite values in $path")

    time = data[:, columns["time_s"]]
    isapprox(first(time), 0.0; atol=1e-12) || error("unexpected start time")
    isapprox(last(time), 50.0; atol=1e-8) || error("unexpected stop time")

    reference = hcat(
        data[:, columns["reference_x_m"]],
        data[:, columns["reference_y_m"]],
        data[:, columns["reference_z_m"]],
    )
    position = hcat(
        data[:, columns["position_x_m"]],
        data[:, columns["position_y_m"]],
        data[:, columns["position_z_m"]],
    )
    error_norm = sqrt.(sum(abs2, reference - position; dims=2))[:, 1]
    terminal = error_norm[time .>= 45.0]

    max_orthogonality_error = 0.0
    max_determinant_error = 0.0
    for row in axes(data, 1)
        rotation = [
            data[row, columns["rotation_11"]] data[row, columns["rotation_12"]] data[row, columns["rotation_13"]]
            data[row, columns["rotation_21"]] data[row, columns["rotation_22"]] data[row, columns["rotation_23"]]
            data[row, columns["rotation_31"]] data[row, columns["rotation_32"]] data[row, columns["rotation_33"]]
        ]
        max_orthogonality_error = max(
            max_orthogonality_error,
            maximum(abs.(transpose(rotation) * rotation - I(3))),
        )
        max_determinant_error = max(max_determinant_error, abs(det(rotation) - 1.0))
    end

    body_rates = hcat(
        data[:, columns["body_rate_1_radps"]],
        data[:, columns["body_rate_2_radps"]],
        data[:, columns["body_rate_3_radps"]],
    )
    motors = hcat(
        data[:, columns["motor_command_1"]],
        data[:, columns["motor_command_2"]],
        data[:, columns["motor_command_3"]],
        data[:, columns["motor_command_4"]],
    )
    max_body_rate = maximum(abs.(body_rates))
    max_motor_q = maximum(abs2, motors)
    physical_pass =
        max_orthogonality_error <= 1e-6 &&
        max_determinant_error <= 1e-6 &&
        max_body_rate <= 20.0 &&
        max_motor_q <= 3600.0 + 1e-8

    rmse = sqrt(mean(abs2, error_norm))
    peak = maximum(error_norm)
    terminal_mean = mean(terminal)
    absolute_pass = physical_pass && peak <= 0.50 && terminal_mean <= 0.05
    return (
        rmse_m=rmse,
        peak_m=peak,
        p95_m=quantile(error_norm, 0.95),
        terminal_mean_m=terminal_mean,
        max_rotation_orthogonality_error=max_orthogonality_error,
        max_rotation_determinant_error=max_determinant_error,
        max_body_rate_radps=max_body_rate,
        max_motor_q=max_motor_q,
        physical_pass=physical_pass,
        absolute_pass=absolute_pass,
        raw_sha256=sha256_upper(path),
    )
end

function resolve_raw(
    execution_root::String,
    case_id::AbstractString,
    controller::AbstractString,
)
    nested = joinpath(execution_root, case_id, controller, "raw.csv")
    packaged = joinpath(execution_root, controller, "$case_id.csv")
    matches = filter(isfile, (nested, packaged))
    length(matches) == 1 || error(
        "expected exactly one raw file for $case_id/$controller; found $(length(matches))",
    )
    return first(matches)
end

function portable_raw_path(path::String, execution_root::String)
    return replace(relpath(path, execution_root), '\\' => '/')
end

function wilson_lower(successes::Int, total::Int)
    total > 0 || return NaN
    p = successes / total
    z = WILSON_Z_ONE_SIDED_95
    denominator = 1 + z^2 / total
    centre = p + z^2 / (2 * total)
    spread = z * sqrt(p * (1 - p) / total + z^2 / (4 * total^2))
    return max(0.0, (centre - spread) / denominator)
end

function exact_two_sided_sign_p(wins::Int, losses::Int)
    effective = wins + losses
    effective == 0 && return 1.0
    tail = min(wins, losses)
    numerator = sum(binomial(big(effective), index) for index in 0:tail)
    return min(1.0, 2 * Float64(numerator) / 2.0^effective)
end

function bootstrap_median_ci(values::Vector{Float64})
    rng = MersenneTwister(BOOTSTRAP_SEED)
    count = length(values)
    estimates = Vector{Float64}(undef, BOOTSTRAP_COUNT)
    for iteration in 1:BOOTSTRAP_COUNT
        estimates[iteration] = median(values[rand(rng, 1:count, count)])
    end
    return quantile(estimates, 0.025), quantile(estimates, 0.975)
end

function controller_summary(name::String, rows)
    rmse = Float64[row.metrics.rmse_m for row in rows]
    physical_count = count(row -> row.metrics.physical_pass, rows)
    absolute_count = count(row -> row.metrics.absolute_pass, rows)
    return (
        controller=name,
        n=length(rows),
        rmse_median_m=median(rmse),
        rmse_q1_m=quantile(rmse, 0.25),
        rmse_q3_m=quantile(rmse, 0.75),
        rmse_p95_m=quantile(rmse, 0.95),
        rmse_max_m=maximum(rmse),
        rmse_mean_m=mean(rmse),
        rmse_sample_std_m=std(rmse),
        physical_pass_count=physical_count,
        physical_pass_rate=physical_count / length(rows),
        physical_wilson_lower_95=wilson_lower(physical_count, length(rows)),
        absolute_pass_count=absolute_count,
        absolute_pass_rate=absolute_count / length(rows),
        absolute_wilson_lower_95=wilson_lower(absolute_count, length(rows)),
    )
end

function csv_value(value)
    value isa Bool && return lowercase(string(value))
    value isa AbstractFloat && return @sprintf("%.17g", value)
    return string(value)
end

function json_number(value::Real)
    return @sprintf("%.17g", Float64(value))
end

function write_outputs(output::String, samples, metrics_rows, paired_rows, summaries, stats, representatives)
    metrics_buffer = IOBuffer()
    println(metrics_buffer, "case_id,controller,lift_scale,mass_scale,inertia_scale,rmse_m,peak_m,p95_m,terminal_mean_m,max_rotation_orthogonality_error,max_rotation_determinant_error,max_body_rate_radps,max_motor_q,physical_pass,absolute_pass,raw_sha256,raw_path")
    for row in metrics_rows
        values = [
            row.case_id, row.controller, row.lift_scale, row.mass_scale, row.inertia_scale,
            row.metrics.rmse_m, row.metrics.peak_m, row.metrics.p95_m,
            row.metrics.terminal_mean_m, row.metrics.max_rotation_orthogonality_error,
            row.metrics.max_rotation_determinant_error, row.metrics.max_body_rate_radps,
            row.metrics.max_motor_q, row.metrics.physical_pass, row.metrics.absolute_pass,
            row.metrics.raw_sha256, row.raw_path,
        ]
        println(metrics_buffer, join(csv_value.(values), ','))
    end
    atomic_write(joinpath(output, "controller_metrics.csv"), String(take!(metrics_buffer)))

    pair_buffer = IOBuffer()
    println(pair_buffer, "case_id,lift_scale,mass_scale,inertia_scale,pid_rmse_m,main_rmse_m,main_pid_rmse_ratio,rmse_reduction_percent,pid_peak_m,main_peak_m,pid_terminal_mean_m,main_terminal_mean_m,main_wins,tie,both_physical_pass,both_absolute_pass")
    for row in paired_rows
        values = [
            row.case_id, row.lift_scale, row.mass_scale, row.inertia_scale,
            row.pid.rmse_m, row.main.rmse_m, row.ratio, row.reduction_percent,
            row.pid.peak_m, row.main.peak_m, row.pid.terminal_mean_m,
            row.main.terminal_mean_m, row.main_wins, row.tie,
            row.pid.physical_pass && row.main.physical_pass,
            row.pid.absolute_pass && row.main.absolute_pass,
        ]
        println(pair_buffer, join(csv_value.(values), ','))
    end
    atomic_write(joinpath(output, "paired_results.csv"), String(take!(pair_buffer)))

    summary_buffer = IOBuffer()
    println(summary_buffer, "controller,n,rmse_median_m,rmse_q1_m,rmse_q3_m,rmse_p95_m,rmse_max_m,rmse_mean_m,rmse_sample_std_m,physical_pass_count,physical_pass_rate,physical_wilson_lower_95,absolute_pass_count,absolute_pass_rate,absolute_wilson_lower_95")
    for row in summaries
        println(summary_buffer, join(csv_value.(collect(row)), ','))
    end
    atomic_write(joinpath(output, "controller_summary.csv"), String(take!(summary_buffer)))

    stats_buffer = IOBuffer()
    println(stats_buffer, "metric,value")
    for (name, value) in Base.pairs(stats)
        println(stats_buffer, "$name,$(csv_value(value))")
    end
    atomic_write(joinpath(output, "statistical_summary.csv"), String(take!(stats_buffer)))

    representative_buffer = IOBuffer()
    println(representative_buffer, "selection_rule,case_id,main_rmse_m,rmse_reduction_percent")
    for row in representatives
        println(
            representative_buffer,
            join(
                csv_value.([
                    row.selection_rule, row.case.case_id, row.case.main.rmse_m,
                    row.case.reduction_percent,
                ]),
                ',',
            ),
        )
    end
    atomic_write(joinpath(output, "representative_cases.csv"), String(take!(representative_buffer)))

    pid = summaries[1]
    main = summaries[2]
    markdown = """# 随机参数配对验证统计表

| 控制器 | n | RMSE中位数 [Q1, Q3] / m | 95%分位数 / m | 最大值 / m | 物理有效 |
|---|---:|---:|---:|---:|---:|
| PID | $(pid.n) | $(@sprintf("%.5f [%.5f, %.5f]", pid.rmse_median_m, pid.rmse_q1_m, pid.rmse_q3_m)) | $(@sprintf("%.5f", pid.rmse_p95_m)) | $(@sprintf("%.5f", pid.rmse_max_m)) | $(pid.physical_pass_count)/$(pid.n) |
| RA-GCA-CGHTE | $(main.n) | $(@sprintf("%.5f [%.5f, %.5f]", main.rmse_median_m, main.rmse_q1_m, main.rmse_q3_m)) | $(@sprintf("%.5f", main.rmse_p95_m)) | $(@sprintf("%.5f", main.rmse_max_m)) | $(main.physical_pass_count)/$(main.n) |

配对胜出$(stats.main_wins)/$(stats.sample_count)组，中位RMSE降幅为$(@sprintf("%.2f", stats.median_reduction_percent))%，95% bootstrap区间为[$(@sprintf("%.2f", stats.bootstrap_ci_low_percent))%，$(@sprintf("%.2f", stats.bootstrap_ci_high_percent))%]；双侧精确符号检验`p=$(@sprintf("%.6g", stats.sign_test_p_two_sided))`。
"""
    atomic_write(joinpath(output, "report_table.md"), markdown)

    json = """{
  "schema_version": 1,
  "experiment_id": "PARAM_MC20_PID_vs_RA-GCA-CGHTE",
  "sample_count": $(stats.sample_count),
  "main_wins": $(stats.main_wins),
  "pid_wins": $(stats.pid_wins),
  "ties": $(stats.ties),
  "median_rmse_reduction_percent": $(json_number(stats.median_reduction_percent)),
  "bootstrap": {
    "samples": $BOOTSTRAP_COUNT,
    "seed": $BOOTSTRAP_SEED,
    "ci_level": 0.95,
    "method": "percentile_median_paired_reduction",
    "low_percent": $(json_number(stats.bootstrap_ci_low_percent)),
    "high_percent": $(json_number(stats.bootstrap_ci_high_percent))
  },
  "sign_test": {
    "method": "exact_two_sided",
    "effective_n": $(stats.sign_effective_n),
    "tie_tolerance_m": $(json_number(TIE_TOLERANCE_M)),
    "p_value": $(json_number(stats.sign_test_p_two_sided))
  },
  "sample_manifest_sha256": "$(stats.sample_manifest_sha256)",
  "software": "Syslab Julia $(VERSION)"
}
"""
    atomic_write(joinpath(output, "statistical_summary.json"), json)
end

function main(execution_root::String, sample_manifest::String, output::String)
    ispath(output) && error("refusing to reuse analysis output directory: $output")
    samples = read_samples(sample_manifest)
    metrics_rows = NamedTuple[]
    paired_rows = NamedTuple[]

    for sample in samples
        pid_path = resolve_raw(execution_root, sample.case_id, "PID")
        main_path = resolve_raw(execution_root, sample.case_id, "RA-GCA-CGHTE")
        pid = controller_metrics(pid_path)
        formal = controller_metrics(main_path)
        push!(
            metrics_rows,
            merge(
                sample,
                (
                    controller="PID",
                    metrics=pid,
                    raw_path=portable_raw_path(pid_path, execution_root),
                ),
            ),
        )
        push!(
            metrics_rows,
            merge(
                sample,
                (
                    controller="RA-GCA-CGHTE",
                    metrics=formal,
                    raw_path=portable_raw_path(main_path, execution_root),
                ),
            ),
        )
        difference = formal.rmse_m - pid.rmse_m
        tie = abs(difference) <= TIE_TOLERANCE_M
        push!(
            paired_rows,
            merge(
                sample,
                (
                    pid=pid,
                    main=formal,
                    ratio=formal.rmse_m / pid.rmse_m,
                    reduction_percent=100 * (1 - formal.rmse_m / pid.rmse_m),
                    main_wins=!tie && difference < 0,
                    tie=tie,
                ),
            ),
        )
    end

    pid_rows = [row for row in metrics_rows if row.controller == "PID"]
    main_rows = [row for row in metrics_rows if row.controller == "RA-GCA-CGHTE"]
    summaries = [
        controller_summary("PID", pid_rows),
        controller_summary("RA-GCA-CGHTE", main_rows),
    ]

    reductions = Float64[row.reduction_percent for row in paired_rows]
    wins = count(row -> row.main_wins, paired_rows)
    ties = count(row -> row.tie, paired_rows)
    losses = SAMPLE_COUNT - wins - ties
    ci_low, ci_high = bootstrap_median_ci(reductions)
    stats = (
        sample_count=SAMPLE_COUNT,
        main_wins=wins,
        pid_wins=losses,
        ties=ties,
        sign_effective_n=wins + losses,
        sign_test_p_two_sided=exact_two_sided_sign_p(wins, losses),
        median_reduction_percent=median(reductions),
        bootstrap_ci_low_percent=ci_low,
        bootstrap_ci_high_percent=ci_high,
        sample_manifest_sha256=sha256_upper(sample_manifest),
    )

    worst_main = paired_rows[argmax([row.main.rmse_m for row in paired_rows])]
    ordered = sort(
        paired_rows;
        by=row -> (abs(row.reduction_percent - stats.median_reduction_percent), row.case_id),
    )
    median_case = first(row for row in ordered if row.case_id != worst_main.case_id)
    representatives = [
        (selection_rule="maximum_main_rmse", case=worst_main),
        (selection_rule="closest_to_median_reduction", case=median_case),
    ]

    mkpath(output)
    write_outputs(output, samples, metrics_rows, paired_rows, summaries, stats, representatives)
    println("analysis_status=pass")
    println("sample_count=$(stats.sample_count)")
    println("main_wins=$(stats.main_wins)")
    println("median_reduction_percent=$(stats.median_reduction_percent)")
    println("bootstrap_ci=[$ci_low,$ci_high]")
    println("sign_test_p=$(stats.sign_test_p_two_sided)")
end

length(ARGS) == 3 || error(
    "usage: analyze_parameter_random20.jl RAW_ROOT SAMPLE_MANIFEST OUTPUT_DIR",
)
main(abspath(ARGS[1]), abspath(ARGS[2]), abspath(ARGS[3]))
