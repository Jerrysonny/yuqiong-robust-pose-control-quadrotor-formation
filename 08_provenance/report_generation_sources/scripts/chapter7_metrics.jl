using Dates
using SHA
using Statistics
using TOML

length(ARGS) == 2 || error("usage: recompute_chapter7_formal.jl PACKAGE_ROOT OUTPUT_ROOT")

const PACKAGE_ROOT = abspath(ARGS[1])
const OUTPUT_ROOT = abspath(ARGS[2])
const SCRIPT_ROOT = joinpath(PACKAGE_ROOT, "02_scripts", "syslab")
const CONFIG_PATH = joinpath(PACKAGE_ROOT, "config", "campaign.toml")
const RAW_ROOT = joinpath(PACKAGE_ROOT, "06_supplementary_evidence", "ra_gca_cg_hte_32_raw")
const FROZEN_TABLE_PATH = joinpath(PACKAGE_ROOT, "04_results", "report_evidence", "09_formation_pp_cbf.csv")

for path in (PACKAGE_ROOT, SCRIPT_ROOT, CONFIG_PATH, RAW_ROOT, FROZEN_TABLE_PATH)
    ispath(path) || error("required input is missing: $path")
end

include(joinpath(SCRIPT_ROOT, "CampaignMetrics.jl"))
using .CampaignMetrics

const F8 = CampaignMetrics.F8
const C8 = F8.CanonicalMetricsV8
const CASE_IDS = ("Scene07B", "Scene07COff", "Scene07COnPredictiveV5C")

mkpath(OUTPUT_ROOT)

sha256_file(path) = bytes2hex(open(SHA.sha256, path))

function csv_write(path, headers, columns)
    length(headers) == length(columns) || error("CSV header/column count mismatch")
    rows = isempty(columns) ? 0 : length(columns[1])
    all(length(column) == rows for column in columns) || error("CSV columns have unequal lengths")
    mkpath(dirname(path))
    open(path, "w") do io
        println(io, join(C8.csv_escape.(headers), ','))
        for row in 1:rows
            println(io, join(C8.csv_escape.([column[row] for column in columns]), ','))
        end
    end
end

function dictionary_csv_write(path, rows::Vector{Dict{String,Any}}, headers)
    columns = [[get(row, header, nothing) for row in rows] for header in headers]
    csv_write(path, headers, columns)
end

function text_csv_rows(path)
    lines = readlines(path)
    isempty(lines) && error("CSV is empty: $path")
    headers = C8.split_csv_line(lines[1])
    rows = Dict{String,String}[]
    for line in lines[2:end]
        isempty(strip(line)) && continue
        values = C8.split_csv_line(line)
        length(values) == length(headers) || error("CSV row width mismatch: $path")
        push!(rows, Dict(headers[index] => values[index] for index in eachindex(headers)))
    end
    return rows
end

function centroid(array)
    return dropdims(mean(array; dims=2); dims=2)
end

function vector_norm_rows(array)
    return sqrt.(dropdims(sum(abs2, array; dims=2); dims=2))
end

function cumulative_trapezoid(time, values)
    # 梯形积分保留每个时刻之前的累计风险暴露量。
    output = zeros(Float64, length(time))
    for index in 2:length(time)
        output[index] = output[index - 1] +
            0.5 * (values[index - 1] + values[index]) * (time[index] - time[index - 1])
    end
    return output
end

function report_metrics(result)
    # 报告指标从全量评价结果中选取可公开复算的字段。
    data = result.data
    actual_centroid = centroid(data.actual)
    commanded_centroid = centroid(data.commanded)
    centroid_error = vector_norm_rows(actual_centroid - commanded_centroid)
    member_rmse = [sqrt(mean(abs2, data.commanded_error[:, member])) for member in 1:3]
    follower_rmse = [sqrt(mean(abs2, data.formation_error[:, follower])) for follower in 1:2]
    diagnostics = data.diagnostics
    active = diagnostics === nothing ? nothing : diagnostics[:, 4] .> 0.5
    return Dict{String,Any}(
        "centroid_commanded_rmse_m" => sqrt(mean(abs2, centroid_error)),
        "centroid_commanded_peak_m" => maximum(centroid_error),
        "member_commanded_rmse_1_m" => member_rmse[1],
        "member_commanded_rmse_2_m" => member_rmse[2],
        "member_commanded_rmse_3_m" => member_rmse[3],
        "member_commanded_rmse_range_m" => maximum(member_rmse) - minimum(member_rmse),
        "member_commanded_rmse_std_m" => std(member_rmse; corrected=false),
        "follower_formation_rmse_2_m" => follower_rmse[1],
        "follower_formation_rmse_3_m" => follower_rmse[2],
        "cbf_active_duration_s" => active === nothing ? nothing :
            C8.trapezoid(Float64.(active), data.time),
        "cbf_active_sample_count" => active === nothing ? nothing : count(active),
        "infeasible_sample_count" => diagnostics === nothing ? nothing :
            count(diagnostics[:, 6] .> 0.5),
        "hold_sample_count" => diagnostics === nothing ? nothing :
            count(diagnostics[:, 7] .> 0.5),
    )
end

config = TOML.parsefile(CONFIG_PATH)
expected_version = Int(config["hte_diagnostics"]["formal_version_code"])
safe_distance = Float64(config["comparison_gates"]["formation_minimum_distance_m"])

# 三个场景分别覆盖队形变换、安全关闭和安全开启。
results = Dict{String,Any}()
for case_id in CASE_IDS
    raw_path = joinpath(RAW_ROOT, case_id * ".csv")
    results[case_id] = CampaignMetrics.evaluate_formation_file(raw_path;
        controller_id="RA-GCA-CGHTE", case_id=case_id,
        config_path=CONFIG_PATH, expected_hte_version=expected_version)
end

frozen_rows = Dict(row["case_id"] => row for row in text_csv_rows(FROZEN_TABLE_PATH))
frozen_metric_fields = ("minimum_pairwise_distance_m", "risk_exposure_below_0_60_m_s",
    "three_uav_global_position_tracking_rmse_m", "formation_rmse_m")
computed_metric_fields = ("minimum_pairwise_distance_m", "safety_violation_duration_s",
    "tracking_commanded_rmse_m", "formation_rmse_m")
for case_id in CASE_IDS
    haskey(frozen_rows, case_id) || error("case is absent from frozen report evidence: $case_id")
    frozen = frozen_rows[case_id]
    computed = results[case_id].metrics
    for (frozen_field, computed_field) in zip(frozen_metric_fields, computed_metric_fields)
        isempty(frozen[frozen_field]) && continue
        delta = abs(parse(Float64, frozen[frozen_field]) - Float64(computed[computed_field]))
        delta <= 1.0e-12 || error(
            "frozen evidence mismatch: $case_id/$computed_field delta=$delta")
    end
    raw_path = joinpath(RAW_ROOT, case_id * ".csv")
    lowercase(frozen["raw_sha256"]) == lowercase(sha256_file(raw_path)) ||
        error("raw SHA256 mismatch: $case_id")
end

metrics_rows = Dict{String,Any}[]
summary = Dict{String,Any}(
    "generated_utc" => string(now(UTC)),
    "software" => "Syslab Julia " * string(VERSION),
    "config_path" => CONFIG_PATH,
    "config_sha256" => sha256_file(CONFIG_PATH),
    "safe_distance_m" => safe_distance,
    "cases" => Dict{String,Any}(),
)

for case_id in CASE_IDS
    result = results[case_id]
    derived = report_metrics(result)
    raw_path = joinpath(RAW_ROOT, case_id * ".csv")
    combined = merge(copy(result.metrics), derived, Dict{String,Any}(
        "raw_path" => raw_path,
        "raw_sha256" => sha256_file(raw_path),
        "metric_script_path" => abspath(@__FILE__),
    ))
    summary["cases"][case_id] = combined
    row = Dict{String,Any}("case_id" => case_id)
    merge!(row, combined)
    push!(metrics_rows, row)
end

# PP-CBF收益和跟踪代价必须使用同一对场景计算。
off = results["Scene07COff"]
on = results["Scene07COnPredictiveV5C"]
summary["pp_cbf_comparison"] = Dict{String,Any}(
    "minimum_distance_gain_m" => on.metrics["minimum_pairwise_distance_m"] -
        off.metrics["minimum_pairwise_distance_m"],
    "minimum_distance_gain_percent" => 100.0 *
        (on.metrics["minimum_pairwise_distance_m"] / off.metrics["minimum_pairwise_distance_m"] - 1.0),
    "risk_exposure_reduction_s" => off.metrics["safety_violation_duration_s"] -
        on.metrics["safety_violation_duration_s"],
    "global_tracking_rmse_increase_m" => on.metrics["tracking_commanded_rmse_m"] -
        off.metrics["tracking_commanded_rmse_m"],
    "global_tracking_rmse_increase_percent" => 100.0 *
        (on.metrics["tracking_commanded_rmse_m"] / off.metrics["tracking_commanded_rmse_m"] - 1.0),
    "formation_rmse_increase_m" => on.metrics["formation_rmse_m"] -
        off.metrics["formation_rmse_m"],
)

metric_headers = [
    "case_id", "controller_id", "minimum_pairwise_distance_m",
    "safety_violation_duration_s", "tracking_commanded_rmse_m", "formation_rmse_m",
    "formation_peak_m", "transition_recovery_time_s", "centroid_commanded_rmse_m",
    "centroid_commanded_peak_m", "member_commanded_rmse_1_m",
    "member_commanded_rmse_2_m", "member_commanded_rmse_3_m",
    "member_commanded_rmse_range_m", "follower_formation_rmse_2_m",
    "follower_formation_rmse_3_m", "cbf_reference_correction_energy_m2_s",
    "reference_correction_peak_m", "cbf_active_fraction", "cbf_active_duration_s",
    "maximum_projection_correction_mps2", "minimum_final_hocbf_residual",
    "infeasible_sample_count", "hold_sample_count", "raw_path", "raw_sha256",
]

dictionary_csv_write(joinpath(OUTPUT_ROOT, "chapter7_formal_metrics.csv"), metrics_rows, metric_headers)
C8.write_json(joinpath(OUTPUT_ROOT, "chapter7_formal_metrics.json"), summary)

formation = results["Scene07B"]
formation_data = formation.data
formation_time = formation_data.time
actual_centroid = centroid(formation_data.actual)
commanded_centroid = centroid(formation_data.commanded)
centroid_error = vector_norm_rows(actual_centroid - commanded_centroid)
formation_headers = String["time_s"]
formation_columns = Any[formation_time]
for vehicle in 1:3, axis in 1:3
    push!(formation_headers, "uav$(vehicle)_actual_$(('x', 'y', 'z')[axis])_m")
    push!(formation_columns, formation_data.actual[:, vehicle, axis])
end
for vehicle in 1:3, axis in 1:3
    push!(formation_headers, "uav$(vehicle)_commanded_$(('x', 'y', 'z')[axis])_m")
    push!(formation_columns, formation_data.commanded[:, vehicle, axis])
end
append!(formation_headers, ["formation_error_follower2_m", "formation_error_follower3_m",
    "formation_error_max_m", "centroid_commanded_error_m", "member1_commanded_error_m",
    "member2_commanded_error_m", "member3_commanded_error_m", "minimum_pairwise_distance_m"])
append!(formation_columns, Any[
    formation_data.formation_error[:, 1], formation_data.formation_error[:, 2],
    vec(maximum(formation_data.formation_error; dims=2)), centroid_error,
    formation_data.commanded_error[:, 1], formation_data.commanded_error[:, 2],
    formation_data.commanded_error[:, 3], vec(minimum(formation_data.pairwise; dims=2)),
])
csv_write(joinpath(OUTPUT_ROOT, "figure_7_1_source.csv"), formation_headers, formation_columns)

off_time = off.data.time
on_time = on.data.time
length(off_time) == length(on_time) && all(abs.(off_time - on_time) .<= 1.0e-12) ||
    error("PP-CBF off/on time grids do not match")
off_minimum = vec(minimum(off.data.pairwise; dims=2))
on_minimum = vec(minimum(on.data.pairwise; dims=2))
off_exposure = cumulative_trapezoid(off_time, Float64.(off_minimum .< safe_distance))
on_exposure = cumulative_trapezoid(on_time, Float64.(on_minimum .< safe_distance))
csv_write(joinpath(OUTPUT_ROOT, "figure_7_2_source.csv"),
    ["time_s", "pp_cbf_off_minimum_distance_m", "pp_cbf_on_minimum_distance_m",
     "project_evaluation_distance_m", "pp_cbf_off_cumulative_exposure_s",
     "pp_cbf_on_cumulative_exposure_s"],
    Any[off_time, off_minimum, on_minimum, fill(safe_distance, length(off_time)),
        off_exposure, on_exposure])

on_diagnostics = on.data.diagnostics
on_diagnostics === nothing && error("PP-CBF diagnostics are missing")
correction_max = vec(maximum(on.data.correction; dims=2))
correction_rms = sqrt.(vec(mean(abs2, on.data.correction; dims=2)))
csv_write(joinpath(OUTPUT_ROOT, "figure_A_1_source.csv"),
    ["time_s", "reference_correction_max_m", "reference_correction_rms_m",
     "pp_cbf_active", "hocbf_residual", "projection_correction_mps2",
     "infeasible", "output_hold", "minimum_pairwise_distance_m",
     "project_evaluation_distance_m"],
    Any[on_time, correction_max, correction_rms, on_diagnostics[:, 4],
        on_diagnostics[:, 2], on_diagnostics[:, 5], on_diagnostics[:, 6],
        on_diagnostics[:, 7], on_minimum, fill(safe_distance, length(on_time))])

# 冻结候选表区分正式数字和仍需审计的派生数字。
freeze_rows = Dict{String,Any}[]
for row in metrics_rows
    case_id = row["case_id"]
    for (metric, unit, definition) in (
            ("minimum_pairwise_distance_m", "m", "任意两机中心距离的全时域最小值"),
            ("safety_violation_duration_s", "s", "最小机间距低于项目实验评价距离的梯形积分时长"),
            ("tracking_commanded_rmse_m", "m", "三机相对监督后位置指令的全局位置跟踪RMSE"),
            ("formation_rmse_m", "m", "两架跟随机相对领机的队形位移误差RMSE"),
            ("cbf_reference_correction_energy_m2_s", "m^2*s", "监督后与名义位置指令差的平方时间积分"),
            ("cbf_active_fraction", "1", "监督器激活样本占全部样本的比例"),
            ("centroid_commanded_rmse_m", "m", "三机质心相对监督后指令质心的跟踪RMSE"),
            ("member_commanded_rmse_range_m", "m", "三架成员位置跟踪RMSE的极差"))
        push!(freeze_rows, Dict{String,Any}(
            "case_id" => case_id,
            "metric" => metric,
            "value" => get(row, metric, nothing),
            "unit" => unit,
            "definition_zh" => definition,
            "evidence_status" => metric in ("minimum_pairwise_distance_m",
                "safety_violation_duration_s", "tracking_commanded_rmse_m", "formation_rmse_m") ?
                "已登记正式证据" : "新增证据，待中央冻结",
            "raw_path" => row["raw_path"],
            "raw_sha256" => row["raw_sha256"],
            "metric_script" => abspath(@__FILE__),
        ))
    end
end

freeze_headers = ["case_id", "metric", "value", "unit", "definition_zh",
    "evidence_status", "raw_path", "raw_sha256", "metric_script"]
dictionary_csv_write(joinpath(OUTPUT_ROOT, "chapter7_digital_freeze_candidate.csv"),
    freeze_rows, freeze_headers)

manifest_rows = Dict{String,Any}[]
for path in sort(readdir(OUTPUT_ROOT; join=true))
    isfile(path) || continue
    push!(manifest_rows, Dict{String,Any}(
        "file" => basename(path), "bytes" => filesize(path), "sha256" => sha256_file(path)))
end
dictionary_csv_write(joinpath(OUTPUT_ROOT, "derived_manifest.csv"), manifest_rows,
    ["file", "bytes", "sha256"])

println("chapter 7 formal recomputation: PASS")
println("output_root=" * OUTPUT_ROOT)
