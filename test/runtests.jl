using EcmwfRequests
using Test

raw_req = "test/testreq.req"
yaml_req = "test/testreq.yaml"

newreq_path = "test/newreq.yaml"
@testset "EcmwfRequests.jl" begin
    # Write your tests here.
    line1 = "    stream  =  oper, "
    @test !isnothing(EcmwfRequests.matchline(line1))
    line2 = "retrieve, "
    @test isnothing(EcmwfRequests.matchline(line2))
    req1 = MarsRequest(raw_req)
    @test req1["time"] == "00"
    req2 = MarsRequest(yaml_req)
    @test req2["stream"] == "oper"

    area = "52/4/48/8"
    req1["area"] = area
    EcmwfRequests.writereq(newreq_path, req1)

    newreq = MarsRequest(newreq_path)
    EcmwfRequests.runmars(newreq)
    rm(newreq_path)
    rm(strip(newreq["target"], '\"'))
end
