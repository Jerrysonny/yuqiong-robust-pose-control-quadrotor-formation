module CanonicalMetricsV8

include(joinpath(@__DIR__, "CanonicalMetricsV7.jl"))
using .CanonicalMetricsV7

export EvidenceContext, SO3_V8_CANDIDATE, SO3_V8_CONTROLLER, SO3_V8_TRACK,
    V2B_TRACK, validate_context, evaluate_file, decorate_result, availability_state,
    nullable_ratio, NumericTable, read_numeric_csv, find_series, trapezoid,
    motor_smoothness, write_row_csv, write_json, csv_escape, split_csv_line,
    infer_scene, expected_stop_time, config_value, AXES, ATTITUDE

const SO3_V8_CANDIDATE = "so3_v8_px4alloc"
const SO3_V8_CONTROLLER = "so3_v8_px4alloc"
const SO3_V8_TRACK = "so3_v8"
const V2B_TRACK = "v2b"
const VALID_TRACKS = (SO3_V8_TRACK, V2B_TRACK)

struct EvidenceContext
    candidate_id::String
    controller_id::String
    evidence_track::String
    experiment_id::String
    run_id::Union{Nothing,String}
end

function EvidenceContext(; candidate_id, controller_id, evidence_track,
        experiment_id, run_id=nothing)
    context = EvidenceContext(string(candidate_id), string(controller_id),
        string(evidence_track), string(experiment_id),
        run_id === nothing ? nothing : string(run_id))
    validate_context(context)
    return context
end

function validate_context(context::EvidenceContext)
    context.evidence_track in VALID_TRACKS ||
        error("unknown evidence track: $(context.evidence_track)")
    isempty(strip(context.candidate_id)) && error("candidate_id must not be empty")
    isempty(strip(context.controller_id)) && error("controller_id must not be empty")
    isempty(strip(context.experiment_id)) && error("experiment_id must not be empty")

    controller_is_v2b = occursin("v2b", lowercase(context.controller_id))
    candidate_is_v2b = occursin("v2b", lowercase(context.candidate_id))
    if context.evidence_track == SO3_V8_TRACK
        context.controller_id == SO3_V8_CONTROLLER ||
            error("SO3 v8 evidence must come from controller $SO3_V8_CONTROLLER")
        controller_is_v2b && error("V2B controller cannot be bound to SO3 v8 evidence")
    else
        controller_is_v2b || error("V2B evidence track requires a V2B controller_id")
    end

    if context.candidate_id == SO3_V8_CANDIDATE
        context.evidence_track == SO3_V8_TRACK ||
            error("V2B evidence cannot be transferred to SO3 v8 candidate")
        context.controller_id == SO3_V8_CONTROLLER ||
            error("SO3 v8 candidate requires its own controller evidence")
    elseif candidate_is_v2b
        context.evidence_track == V2B_TRACK ||
            error("V2B candidate must use the V2B evidence track")
    end
    return true
end

availability_state(value) = value === nothing ? "missing" :
    value isa AbstractFloat && !isfinite(value) ? "invalid" : "available"

function nullable_ratio(numerator, denominator; atol=1e-12)
    numerator === nothing && return (nothing, "missing_numerator")
    denominator === nothing && return (nothing, "missing_denominator")
    numerator_value = Float64(numerator)
    denominator_value = Float64(denominator)
    isfinite(numerator_value) || return (nothing, "invalid_numerator")
    isfinite(denominator_value) || return (nothing, "invalid_denominator")
    abs(denominator_value) <= atol && return numerator_value <= atol ?
        (1.0, "both_zero") : (nothing, "not_evaluable_denominator_zero")
    return (numerator_value / denominator_value, "evaluated")
end

function provenance(context::EvidenceContext, evaluation_kind)
    validate_context(context)
    return Dict{String,Any}(
        "schema_version" => 8,
        "candidate_id" => context.candidate_id,
        "controller_id" => context.controller_id,
        "evidence_track" => context.evidence_track,
        "experiment_id" => context.experiment_id,
        "run_id" => context.run_id,
        "evaluation_kind" => string(evaluation_kind),
        "evidence_track_validated" => true)
end

function recompute_all_pass!(gates)
    required = [value for (key, value) in gates
        if key != "scene" && key != "all_pass" && !startswith(key, "evidence_") &&
            value isa Bool]
    gates["all_pass"] = !isempty(required) && all(required)
    return gates
end

function decorate_result(result, context::EvidenceContext; evaluation_kind="canonical")
    metadata = provenance(context, evaluation_kind)
    metrics = merge(copy(result.metrics), metadata)
    gates = copy(result.gates)
    gates["evidence_track_binding"] = true
    gates["evidence_candidate_binding"] = true
    recompute_all_pass!(gates)
    return (; table=result.table, data=result.data, metrics, gates)
end

function evaluate_file(path; context::EvidenceContext, kwargs...)
    validate_context(context)
    result = CanonicalMetricsV7.evaluate_file(path; kwargs...)
    return decorate_result(result, context; evaluation_kind="canonical")
end

const NumericTable = CanonicalMetricsV7.NumericTable
const AXES = CanonicalMetricsV7.AXES
const ATTITUDE = CanonicalMetricsV7.ATTITUDE
read_numeric_csv(args...; kwargs...) = CanonicalMetricsV7.read_numeric_csv(args...; kwargs...)
find_series(args...; kwargs...) = CanonicalMetricsV7.find_series(args...; kwargs...)
trapezoid(args...; kwargs...) = CanonicalMetricsV7.trapezoid(args...; kwargs...)
motor_smoothness(args...; kwargs...) = CanonicalMetricsV7.motor_smoothness(args...; kwargs...)
write_row_csv(args...; kwargs...) = CanonicalMetricsV7.write_row_csv(args...; kwargs...)
write_json(args...; kwargs...) = CanonicalMetricsV7.write_json(args...; kwargs...)
csv_escape(args...; kwargs...) = CanonicalMetricsV7.csv_escape(args...; kwargs...)
split_csv_line(args...; kwargs...) = CanonicalMetricsV7.split_csv_line(args...; kwargs...)
infer_scene(args...; kwargs...) = CanonicalMetricsV7.infer_scene(args...; kwargs...)
expected_stop_time(args...; kwargs...) = CanonicalMetricsV7.expected_stop_time(args...; kwargs...)
config_value(args...; kwargs...) = CanonicalMetricsV7.config_value(args...; kwargs...)

end
