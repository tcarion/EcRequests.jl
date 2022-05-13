using EcmwfRequests
using Test

raw_req = "testreq.req"
yaml_req = "testreq.yaml"

newreq_path = "newreq.yaml"

@testset "EcmwfRequests.jl" begin
    # Write your tests here.
    line1 = "    stream  =  oper, "
    @test !isnothing(EcmwfRequests._matchline(line1))
    line2 = "retrieve, "
    @test isnothing(EcmwfRequests._matchline(line2))
    req1 = EcmwfRequest(raw_req)
    @test req1["time"] == "00"
    req2 = EcmwfRequest(yaml_req)
    @test req2["stream"] == "oper"

    area = "52/4/48/8"
    req1["area"] = area
    EcmwfRequests.writereq(newreq_path, req1)

    newreq = EcmwfRequest(newreq_path)
    EcmwfRequests.runmars(newreq)
    rm(newreq_path)
    rm(strip(newreq["target"], '\"'))
end
