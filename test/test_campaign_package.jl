using Test

const PACKAGE_ROOT = dirname(@__DIR__)
const CAMPAIGN_METRICS = joinpath(PACKAGE_ROOT, "02_scripts", "syslab", "CampaignMetrics.jl")

@testset "package campaign metrics" begin
    @test isfile(CAMPAIGN_METRICS)
    include(CAMPAIGN_METRICS)
    config = CampaignMetrics.load_campaign_config()
    @test length(CampaignMetrics.suite_case_ids(config)) == 32
    @test config["identity"]["formal_id"] == "RA-GCA-CGHTE"
    @test config["identity"]["formal_diagnostic_version"] == 914
    @test config["formal_fixed_parameters"]["activation_covariance_max"] ==
        0.00253218969247675
    @test config["formal_fixed_parameters"]["activation_persistence_s"] == 0.10
    @test config["formal_fixed_parameters"]["scale_rate_limit_per_s"] == 0.868
    sources = CampaignMetrics.frozen_source_manifest()
    @test length(sources) == 5
    @test all(item -> isfile(item["path"]), values(sources))
end
