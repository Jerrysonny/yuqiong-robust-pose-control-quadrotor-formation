module BuildFiveControllerEvidence

using SHA

const PACKAGE_ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const EVIDENCE_ROOT = joinpath(PACKAGE_ROOT, "04_results", "report_evidence")
const COVERAGE_FILE = joinpath(EVIDENCE_ROOT, "01_five_controller_scene_coverage.csv")
const COMMON_FILE = joinpath(EVIDENCE_ROOT, "03_five_controller_common_scenes.csv")
const CONTROLLERS = ["PID", "RA-GCA/Base", "RA-GCA-CGHTE", "CAP-ADRC", "CP-INDI"]
const COMMON_CASES = ["Scene01", "Scene04", "Scene03", "Scene06b"]

file_sha256(path) = uppercase(bytes2hex(sha256(read(path))))

function csv_rows(path)
    isfile(path) || error("missing report evidence: $path")
    lines = readlines(path)
    length(lines) >= 2 || error("empty report evidence: $path")
    return [split(line, ','; keepempty=true) for line in lines[2:end]]
end

function validate_evidence()
    # 固定检查五个控制器在四个公共场景中的20条记录。
    coverage = csv_rows(COVERAGE_FILE)
    common = csv_rows(COMMON_FILE)
    [row[1] for row in coverage] == CONTROLLERS ||
        error("five-controller coverage identity mismatch")
    length(common) == 20 || error("common-scene row count mismatch")
    Set(row[3] for row in common) == Set(CONTROLLERS) ||
        error("common-scene controller identity mismatch")
    for case_id in COMMON_CASES
        count(row -> row[1] == case_id, common) == 5 ||
            error("incomplete common scene: $case_id")
    end
    all(row -> length(row) >= 4 && begin
        value = tryparse(Float64, row[4])
        value !== nothing && isfinite(value) && value >= 0
    end, common) || error("invalid common-scene RMSE")
    return (
        coverage_hash=file_sha256(COVERAGE_FILE),
        common_hash=file_sha256(COMMON_FILE),
    )
end

function external_output(path)
    # 导出目录必须位于封包外且尚未存在。
    isabspath(path) || error("--output must be an absolute path outside the source package")
    output = normpath(abspath(path))
    root_key = rstrip(lowercase(replace(abspath(PACKAGE_ROOT), '\\' => '/')), '/')
    output_key = lowercase(replace(output, '\\' => '/'))
    (output_key == root_key || startswith(output_key, root_key * "/")) &&
        error("--output must be outside the source package")
    ispath(output) && error("--output already exists: $output")
    return output
end

function parse_arguments(arguments)
    arguments == ["--check"] && return (check=true, output=nothing)
    length(arguments) == 2 && arguments[1] == "--output" &&
        return (check=false, output=arguments[2])
    error("usage: build_five_scene_comparison.jl --check | --output ABSOLUTE_PATH")
end

function export_evidence(output, hashes)
    # 只复制两张权威表，并记录来源哈希供复核。
    mkpath(output)
    cp(COVERAGE_FILE, joinpath(output, basename(COVERAGE_FILE)))
    cp(COMMON_FILE, joinpath(output, basename(COMMON_FILE)))
    manifest = joinpath(output, "five_controller_evidence_sha256.csv")
    open(manifest, "w") do stream
        println(stream, "artifact,sha256")
        println(stream, "01_five_controller_scene_coverage.csv,$(hashes.coverage_hash)")
        println(stream, "03_five_controller_common_scenes.csv,$(hashes.common_hash)")
    end
    return manifest
end

function main(arguments=ARGS)
    options = parse_arguments(arguments)
    hashes = validate_evidence()
    if options.check
        println("five_controller_evidence_status=pass")
    else
        output = external_output(options.output)
        manifest = export_evidence(output, hashes)
        println("five_controller_evidence_export=$output")
        println("five_controller_evidence_manifest=$manifest")
    end
    println("controller_count=5")
    println("common_scene_count=4")
    println("common_row_count=20")
    return 0
end

end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    exit(BuildFiveControllerEvidence.main())
end
