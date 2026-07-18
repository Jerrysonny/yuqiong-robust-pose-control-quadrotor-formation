using Dates
using SHA
using Test


function find_project_root(start_path)
    # 向上查找项目标志目录，避免依赖调用时工作目录。
    current = abspath(start_path)
    while true
        isdir(joinpath(current, "A8赛题核心工作区")) && return current
        parent = dirname(current)
        parent == current && error("project root not found from $start_path")
        current = parent
    end
end


const PROJECT_ROOT = find_project_root(@__DIR__)
const CHAPTER_ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const SOURCE_ROOT = joinpath(PROJECT_ROOT, "A8赛题核心工作区", "正式工程双轨收口_20260713")
const PACKAGE_ROOT = joinpath(PROJECT_ROOT, "A8赛题核心工作区", "A8比赛作品完整源文件_20260715")
const OUTPUT_ROOT = joinpath(CHAPTER_ROOT, "02_analysis")
const EVALUATOR_DIR = joinpath(SOURCE_ROOT, "02_scripts", "syslab")
const CONFIG_PATH = joinpath(SOURCE_ROOT, "config", "final_experiment_v2.toml")
const HISTORICAL_SUMMARY = joinpath(SOURCE_ROOT, "04_analysis", "standard_step_v7", "standard_step_summary_v7.csv")
const FROZEN_STEP_EVIDENCE = joinpath(PACKAGE_ROOT, "04_results", "report_evidence", "02_standard_step_pid_vs_main.csv")
const OFFICIAL_MODEL = joinpath(PACKAGE_ROOT, "01_models", "official", "QuadrotorModel", "package.mo")

include(joinpath(EVALUATOR_DIR, "TransientMetricsV7.jl"))
using .TransientMetricsV7
using .TransientMetricsV7.CanonicalMetricsV7


const CASES = [
    (axis="X", axis_index=1, direct_version="direct_v1"),
    (axis="Y", axis_index=2, direct_version="direct_v1"),
    (axis="Z", axis_index=3, direct_version="direct_v4"),
]

const EXPECTED_HASHES = Dict(
    "historical_summary" => "7D347776520FBC6384B899C7B51E0E686F4E888FB83971DC8F4EBE441F9DCDFD",
    "frozen_step_evidence" => "4139CD3B2D59417A57357C57788E6F64A831F4A3B51562A1517759DFCC88F81C",
    "official_model" => "B39A8B23665A3B05CF3FAD406744021F0E65541A02D1EF052D2BD10BA7E76352",
    "raw_X" => "E47015E640592CD88AC831E732742867DF5AD3A7918D63F24C64D5ED574C725F",
    "raw_Y" => "5875ABA30CF757AE1F3EAC2BEF20ED87807B9A1720FB19385E106DF5FF7B0ED1",
    "raw_Z" => "5270D4F91D258113EE7D00CF491C6F133F75D4B9F01EB3B17108581228BBEBC2",
)


sha256_file(path) = uppercase(bytes2hex(sha256(read(path))))


function read_records(path)
    lines = readlines(path)
    isempty(lines) && error("empty CSV: $path")
    header = CanonicalMetricsV7.split_csv_line(lines[1])
    return [Dict(zip(header, CanonicalMetricsV7.split_csv_line(line)))
        for line in lines[2:end] if !isempty(strip(line))]
end


function write_csv(path, columns, rows)
    mkpath(dirname(path))
    open(path, "w") do stream
        println(stream, join(CanonicalMetricsV7.csv_escape.(columns), ','))
        for row in rows
            println(stream, join(CanonicalMetricsV7.csv_escape.([row[column] for column in columns]), ','))
        end
    end
end


function historical_pid_row(records, axis)
    # 历史摘要只提取对应轴的官方PID基准记录。
    matches = filter(row -> row["controller"] == "pid_original" && row["axis"] == axis, records)
    length(matches) == 1 || error("expected one historical PID row for axis $axis")
    return only(matches)
end


function frozen_pid_row(records, axis)
    # 冻结表用于确认报告采用值，不补算缺失的跨算法指标。
    matches = filter(row -> row["controller"] == "PID" && row["axis"] == axis, records)
    length(matches) == 1 || error("expected one frozen PID row for axis $axis")
    return only(matches)
end


function main()
    # 三轴结果、模型来源和冻结证据在同一审计流程中核对。
    mkpath(OUTPUT_ROOT)
    historical = read_records(HISTORICAL_SUMMARY)
    frozen = read_records(FROZEN_STEP_EVIDENCE)
    metric_rows = Dict{String,Any}[]
    plot_rows = Dict{String,Any}[]
    input_hashes = Dict(
        "historical_summary" => sha256_file(HISTORICAL_SUMMARY),
        "frozen_step_evidence" => sha256_file(FROZEN_STEP_EVIDENCE),
        "official_model" => sha256_file(OFFICIAL_MODEL),
        "config" => sha256_file(CONFIG_PATH),
        "transient_evaluator" => sha256_file(joinpath(EVALUATOR_DIR, "TransientMetricsV7.jl")),
        "canonical_evaluator" => sha256_file(joinpath(EVALUATOR_DIR, "CanonicalMetricsV7.jl")),
    )

    @testset "Chapter 2 PID baseline evidence" begin
        @test input_hashes["historical_summary"] == EXPECTED_HASHES["historical_summary"]
        @test input_hashes["frozen_step_evidence"] == EXPECTED_HASHES["frozen_step_evidence"]
        @test input_hashes["official_model"] == EXPECTED_HASHES["official_model"]

        for case in CASES
            raw_path = joinpath(SOURCE_ROOT, "03_results", "standard_step_baselines",
                "pid_original", "Scene01S_$(case.axis)", case.direct_version, "raw.csv")
            raw_hash = sha256_file(raw_path)
            @test raw_hash == EXPECTED_HASHES["raw_$(case.axis)"]

            result = evaluate_standard_step(raw_path; axis=case.axis_index, config_path=CONFIG_PATH)
            old = historical_pid_row(historical, case.axis)
            current = frozen_pid_row(frozen, case.axis)
            metric = result.metrics

            for field in ("tracking_rmse_m", "rise_time_10_90_s", "overshoot_percent",
                    "settling_time_s", "steady_signed_error_m", "steady_abs_error_m",
                    "steady_rmse_m")
                @test isapprox(Float64(metric[field]), parse(Float64, old[field]); atol=1e-12, rtol=1e-12)
            end
            @test old["raw_sha256"] == raw_hash
            @test isempty(strip(current["tracking_rmse_m"]))
            @test isapprox(parse(Float64, current["overshoot_percent"]),
                Float64(metric["overshoot_percent"]); atol=1e-12, rtol=1e-12)

            push!(metric_rows, Dict{String,Any}(
                "axis" => case.axis,
                "rise_time_10_90_s" => metric["rise_time_10_90_s"],
                "overshoot_percent" => metric["overshoot_percent"],
                "settling_time_s" => metric["settling_time_s"],
                "tracking_rmse_m" => metric["tracking_rmse_m"],
                "steady_signed_error_m" => metric["steady_signed_error_m"],
                "steady_abs_error_m" => metric["steady_abs_error_m"],
                "steady_rmse_m" => metric["steady_rmse_m"],
                "raw_path" => raw_path,
                "raw_sha256" => raw_hash,
                "historical_summary_match" => true,
                "frozen_overshoot_match" => true,
                "frozen_pid_rmse_status" => "not_available_for_cross_algorithm_ratio",
            ))

            data = result.data
            for row in eachindex(data.time)
                8.0 - 1e-12 <= data.time[row] <= 20.0 + 1e-12 || continue
                push!(plot_rows, Dict{String,Any}(
                    "axis" => case.axis,
                    "time_s" => data.time[row],
                    "reference_m" => data.reference[row, case.axis_index],
                    "response_m" => data.position[row, case.axis_index],
                    "raw_sha256" => raw_hash,
                ))
            end
        end
    end

    metrics_path = joinpath(OUTPUT_ROOT, "chapter2_pid_baseline_metrics.csv")
    plot_path = joinpath(OUTPUT_ROOT, "chapter2_pid_plot_data.csv")
    audit_path = joinpath(OUTPUT_ROOT, "chapter2_pid_baseline_audit.json")
    write_csv(metrics_path,
        ["axis", "rise_time_10_90_s", "overshoot_percent", "settling_time_s",
            "tracking_rmse_m", "steady_signed_error_m", "steady_abs_error_m",
            "steady_rmse_m", "raw_path", "raw_sha256", "historical_summary_match",
            "frozen_overshoot_match", "frozen_pid_rmse_status"], metric_rows)
    write_csv(plot_path,
        ["axis", "time_s", "reference_m", "response_m", "raw_sha256"], plot_rows)
    CanonicalMetricsV7.write_json(audit_path, Dict{String,Any}(
        "schema_version" => 1,
        "status" => "pass",
        "generated_utc" => Dates.format(now(UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sssZ"),
        "runtime" => "Syslab julia-ty $(VERSION)",
        "metric_contract" => "TransientMetricsV7.evaluate_standard_step",
        "evaluation_window" => "30 s raw; step at 10 s; plot window 8-20 s",
        "input_hashes" => input_hashes,
        "case_count" => length(metric_rows),
        "plot_row_count" => length(plot_rows),
        "metrics_csv" => metrics_path,
        "plot_csv" => plot_path,
        "boundary" => "PID tracking RMSE is retained only as the standalone Chapter 2 baseline metric; the frozen cross-controller CSV leaves PID RMSE empty.",
    ))
    println("chapter2_pid_cases=$(length(metric_rows))")
    println("plot_rows=$(length(plot_rows))")
    println("metrics_csv=$metrics_path")
    println("audit_json=$audit_path")
end


main()
