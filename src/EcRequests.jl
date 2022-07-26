module EcRequests

using PyCall
using DataStructures: OrderedDict
using YAML

export EcRequest, EcRequestType

const ecmwfapi = PyNULL()
const ecmwf_public_server = PyNULL()
const ecmwf_mars_server = PyNULL()

const polytopeapi = PyNULL()
const polytope_client = PyNULL()

function __init__()
    # ecmwfapi won't be able to access mars servers if ssl certification is not deactivated. See https://github.com/JuliaPy/PyCall.jl/issues/987
    py"""
    import ssl
    ssl._create_default_https_context = ssl._create_unverified_context
    """
    copy!(ecmwfapi, pyimport_conda("ecmwfapi", "ecmwf-api-client", "conda-forge"))
    copy!(ecmwf_public_server, ecmwfapi.ECMWFDataServer())
    copy!(ecmwf_mars_server, ecmwfapi.ECMWFService("mars"))

    # Try to import the optional polytope-client package
    try
        copy!(polytopeapi, pyimport_conda("polytope.api", "polytope-client", "conda-forge"))
        copy!(polytope_client, polytopeapi.Client(address = "polytope.ecmwf.int"))
        try
            # Would be better to simply redirect stdout to devnull, but it doesn't work
            tmp_cli = polytopeapi.Client(address = "polytope.ecmwf.int", quiet = true)
            # redirect_stdout(devnull) do 
            tmp_cli.list_collections()
            # end
        catch e
            if e isa PyCall.PyError
                @warn "It seems you don't have credentials for the polytope api."
            else
                throw(e)
            end
        end
    catch

    end
end

const EcRequestType = OrderedDict{String, Any}

function _matchline(line)
    reg = r"(.*)=([^,]*)"
    if occursin("#", line)
        return nothing
    else
        match(reg, line)
    end
end
function _parse_from_raw(path::String)
    lines = readlines(path)

    req = EcRequestType()

    for line in lines
        m = _matchline(line)
        isnothing(m) && continue
        key, value = m.captures
        sep = strip(key) => strip(value)
        push!(req, sep)
    end
    req
end

_isyaml(path) = splitext(path)[2] == ".yaml"
function _parse_from_yaml(path::String)
    YAML.load_file(path; dicttype=EcRequestType)
end

"""
    EcRequest(filename::String)

Read the file `filename` and parse the content as a `$EcRequestType`. `filename` can be in YAML format or in native mars syntax format.
"""
function EcRequest(filename::String)
    if _isyaml(filename)
        _parse_from_yaml(filename)
    else
        _parse_from_raw(filename)
    end
end

"""
    EcRequest(pairs::Vararg{Pair})

Create a `$EcRequestType` from the `pairs`.
"""
function EcRequest(pairs::Vararg{Pair})
    EcRequestType(pairs...)
end

"""
    runmars(req)

Run the request with the ecmwf client.
"""
function runmars(req)
    if !haskey(req, :dataset) || occursin("None", req["dataset"])
        ecmwf_mars_server.execute(req, _format_target(req["target"]))
    else
        ecmwf_public_server.retrieve(req)
    end
end

"""
    runpolytope(req)

Run the request with the polytope client.
"""
function runpolytope(req)
    polytope_client.retrieve("ecmwf-mars", req, _format_target(req["target"]))
end

function writeyaml(dest::String, req) 
    YAML.write_file(dest, req)
    dest
end

function writeraw(dest::String, req)
    open(dest, "w") do io
        # write(io, "retrieve,\n")
        for line in format(req)
            write(io, line)
        end
    end
    dest
end

_format_target(target) = replace(target, "\"" => "") 

"""
    writereq(dest::String, req)

Write the request `req` to the file specified by `dest`. If `dest` has the `.yaml` extension, it's written in YAML format.
If not, the native mars syntax is used. Return `dest`.
"""
function writereq(dest::String, req)
    if _isyaml(dest)
        writeyaml(dest, req)
    else
        writeraw(dest, req)
    end
    dest
end

function format(req)::Vector{String}
    str = ["retrieve,\n"]
    for (name, value) in req
        line = "$name=$value,\n"
        push!(str, line)
    end
    str[end] = strip(str[end], ',')
    str
end

end
