"""Evaluate paired V8/formal-controller CSV evidence without Sysplorer."""

include(joinpath(@__DIR__, "CampaignMetrics.jl"))
using .CampaignMetrics

function usage(stream=stdout)
    println(stream, "usage: julia-ty run_campaign_evaluation.jl \\")
    println(stream, "  --v8-root PATH --formal-root PATH --output ABSOLUTE_PATH \\")
    println(stream, "  [--config PATH] [--formal-controller-id ID] \\")
    println(stream, "  [--formal-diagnostic-version 914] [--case CASE] [--allow-partial]")
end

function require_value(arguments, index, option)
    index < length(arguments) || error("missing value for $option")
    value = arguments[index + 1]
    startswith(value, "--") && error("missing value for $option")
    return value
end

function parse_arguments(arguments)
    # 多次--case会合并为同一工况列表，其余参数只接受单值。
    workspace = dirname(dirname(@__DIR__))
    options = Dict{String,Any}(
        "config" => joinpath(workspace, "config", "campaign.toml"),
        "hte_controller_id" => "RA-GCA-CGHTE", "hte_version" => 914,
        "cases" => String[], "allow_partial" => false, "help" => false,
    )
    index = 1
    while index <= length(arguments)
        option = arguments[index]
        if option == "--help" || option == "-h"
            options["help"] = true
        elseif option == "--allow-partial"
            options["allow_partial"] = true
        elseif option in ("--v8-root", "--formal-root", "--hte-root", "--output",
                "--config", "--formal-controller-id", "--hte-controller-id",
                "--formal-diagnostic-version", "--hte-version", "--case")
            value = require_value(arguments, index, option)
            key = if option in ("--formal-root", "--hte-root")
                "hte_root"
            elseif option in ("--formal-controller-id", "--hte-controller-id")
                "hte_controller_id"
            elseif option in ("--formal-diagnostic-version", "--hte-version")
                "hte_version"
            else
                replace(option[3:end], '-' => '_')
            end
            if option == "--case"
                append!(options["cases"], filter(!isempty, strip.(split(value, ','))))
            elseif option == "--hte-version"
                parsed = tryparse(Int, value)
                parsed === nothing && error("invalid integer for --hte-version: $value")
                options[key] = parsed
            else
                options[key] = value
            end
            index += 1
        else
            error("unknown argument: $option")
        end
        index += 1
    end
    return options
end

function require_external_output(path, workspace)
    # 评价结果必须写到封包外部，保持源文件包只读。
    # 评价结果必须写到包外，防止覆盖冻结证据和manifest。
    isabspath(path) || error("--output must be an absolute path outside the source package")
    output = normpath(abspath(path))
    root = normpath(abspath(workspace))
    output_key = lowercase(replace(output, '\\' => '/'))
    root_key = rstrip(lowercase(replace(root, '\\' => '/')), '/')
    (output_key == root_key || startswith(output_key, root_key * "/")) &&
        error("--output must not be the source package or any directory inside it")
    return output
end

function main(arguments=ARGS)
    # 先完成整批评价，再一次性写出汇总和明细文件。
    # 读取双方同名场景后统一评价，再一次性输出摘要、单案和配对表。
    options = parse_arguments(arguments)
    if options["help"]
        usage()
        return 0
    end
    haskey(options, "v8_root") || error("--v8-root is required")
    haskey(options, "hte_root") || error("--formal-root is required")
    haskey(options, "output") || error("--output is required")
    workspace = dirname(dirname(@__DIR__))
    output = require_external_output(options["output"], workspace)
    selected = isempty(options["cases"]) ? nothing : unique(options["cases"])
    summary = evaluate_campaign(abspath(options["v8_root"]),
        abspath(options["hte_root"]);
        config_path=abspath(options["config"]),
        hte_controller_id=options["hte_controller_id"],
        expected_hte_version=options["hte_version"],
        selected_cases=selected)
    paths = write_campaign_outputs(summary, output)
    full_pass = summary["summary_gates"]["all_pass"]
    partial_pass = options["allow_partial"] &&
        summary["summary_gates"]["required_all_physical_gates"] &&
        summary["summary_gates"]["required_all_paired_case_gates"]
    println("campaign_evaluation_status=" *
        (full_pass ? "pass" : partial_pass ? "partial_pass" : "fail"))
    println("campaign_evaluation_json=" * paths["summary_json"])
    println("campaign_evaluation_cases_csv=" * paths["cases_csv"])
    println("campaign_evaluation_pairs_csv=" * paths["pairs_csv"])
    println("campaign_phase1_decision=" * summary["phase1_decision"])
    return full_pass || partial_pass ? 0 : 1
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    exit(main())
end
