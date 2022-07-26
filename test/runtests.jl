using EcRequests
using Test

raw_req = "testreq.req"
yaml_req = "testreq.yaml"

newreq_path = "newreq.yaml"

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
    EcRequests.writereq(newreq_path, req1)

    newreq = EcRequest(newreq_path)
    EcRequests.runmars(newreq)
    rm(newreq_path)
    rm(strip(newreq["target"], '\"'))
end
