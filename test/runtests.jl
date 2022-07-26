using EcRequests
using Test

testfiles = joinpath(@__DIR__, "files")
raw_req = joinpath(testfiles, "testreq.req")
yaml_req = joinpath(testfiles, "testreq.yaml")

newreq_yaml = "newreq.yaml"
newreq_raw = "newreq"

@testset "EcRequests.jl" begin
    # Write your tests here.
    line1 = "    stream  =  oper, "
    @test !isnothing(EcRequests._matchline(line1))
    line2 = "retrieve, "
    @test isnothing(EcRequests._matchline(line2))
    req1 = EcRequest(raw_req)
    @test req1["time"] == "00"
    req2 = EcRequest(yaml_req)
    @test req2["stream"] == "oper"

    area = "52/4/48/8"
    req1["area"] = area

    mktempdir() do dir
        newreq_yaml_path = joinpath(dir, newreq_yaml)
        newreq_raw_path = joinpath(dir, newreq_raw)
        EcRequests.writereq(newreq_yaml_path, req1)
        EcRequests.writereq(newreq_raw_path, req1)
        @test readlines(newreq_yaml_path)[1] == "stream: \"oper\""
        @test readlines(newreq_raw_path)[1] == "retrieve,"

        newreq = EcRequest(newreq_yaml_path)
        @test newreq["area"] == area
    end



    req3 = EcRequest("stream" => "oper")
    @test req3["stream"] == "oper"

    # EcRequests.runmars(newreq)
    # rm(strip(newreq["target"], '\"'))
end
