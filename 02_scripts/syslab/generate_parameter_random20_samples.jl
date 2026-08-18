using Dates
using Printf
using Random
using SHA

const SAMPLE_COUNT = 20
const SAMPLE_SEED = 20260719
const LOWER = 0.90
const UPPER = 1.10
const PILOT = (1.043413508238, 0.993402648267, 0.962503033058)

function sha256_upper(path::String)
    return uppercase(bytes2hex(open(sha256, path)))
end

function atomic_write(path::String, content::String)
    ispath(path) && error("refusing to overwrite frozen file: $path")
    mkpath(dirname(path))
    temporary = path * ".tmp"
    open(temporary, "w") do stream
        write(stream, content)
    end
    mv(temporary, path)
end

function main(protocol_dir::String)
    output = joinpath(protocol_dir, "sample_manifest.csv")
    sidecar = joinpath(protocol_dir, "sample_manifest.sha256")
    record = joinpath(protocol_dir, "sample_generation_record.txt")
    any(ispath, (output, sidecar, record)) && error("sample manifest is already frozen")

    rng = MersenneTwister(SAMPLE_SEED)
    rows = Tuple{String, Float64, Float64, Float64}[]
    for index in 1:SAMPLE_COUNT
        values = ntuple(_ -> LOWER + (UPPER - LOWER) * rand(rng), 3)
        all(LOWER <= value <= UPPER for value in values) || error("sample out of range")
        maximum(abs.(collect(values) .- collect(PILOT))) > 1e-12 || error("pilot duplicated")
        push!(rows, (@sprintf("MC20_%02d", index), values...))
    end
    length(unique(first.(rows))) == SAMPLE_COUNT || error("duplicate case identifier")

    buffer = IOBuffer()
    println(buffer, "case_id,lift_scale,mass_scale,inertia_scale,seed,draw_index,distribution,formal_statistics_eligible")
    for (index, row) in enumerate(rows)
        @printf(
            buffer,
            "%s,%.15f,%.15f,%.15f,%d,%d,U(0.90;0.10),true\n",
            row[1], row[2], row[3], row[4], SAMPLE_SEED, index,
        )
    end
    atomic_write(output, String(take!(buffer)))

    digest = sha256_upper(output)
    atomic_write(sidecar, "$digest  sample_manifest.csv\n")
    generated = Dates.format(now(UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sssZ")
    atomic_write(
        record,
        join(
            [
                "experiment=PARAM_MC20_PID_vs_RA-GCA-CGHTE",
                "generated_utc=$generated",
                "generator=Syslab Julia $(VERSION)",
                "rng=MersenneTwister",
                "seed=$SAMPLE_SEED",
                "sample_count=$SAMPLE_COUNT",
                "independent_dimensions=lift,mass,inertia",
                "distribution=U(0.90,1.10)",
                "pilot_excluded=true",
                "manifest_sha256=$digest",
            ],
            '\n',
        ) * "\n",
    )
    println("sample_manifest=$output")
    println("sample_count=$SAMPLE_COUNT")
    println("sample_manifest_sha256=$digest")
end

length(ARGS) == 1 || error("usage: generate_samples.jl PROTOCOL_DIR")
main(abspath(ARGS[1]))
