using PyCall

# polytope-client is not yet available in Conda. These lines will be replaced by pyimport_conda("polytope.api", "polytope-client", "conda-forge") in __init__()
const PIP_PACKAGES_OPTIONAL = ["polytope-client"]

sys = pyimport("sys")
subprocess = pyimport("subprocess")

try
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--user", "--upgrade", PIP_PACKAGES_OPTIONAL...])
catch
    @warn "Polytope couldn't be installed. Only requests from ecmwf normal client is available."
end