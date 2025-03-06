# EcRequests

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tcarion.github.io/EcRequests.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tcarion.github.io/EcRequests.jl/dev/)
[![Build Status](https://github.com/tcarion/EcRequests.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/tcarion/EcRequests.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/tcarion/EcRequests.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/tcarion/EcRequests.jl)

`EcRequests.jl` interfaces the [Ecmwf API](https://www.ecmwf.int/en/computing/software/ecmwf-web-api) to retrieve ECMWF meteorological data. It uses [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) to install the needed python client.

## Installation

To install the package:

```julia
] add https://github.com/PrzPaul/EcRequests.jl
```

## Make requests

To be able to make requests to the ECMWF Web API, you will first need to [create an account](https://apps.ecmwf.int/registration/) at ECMWF, and then follow the instructions to set up your API key. Then, you can create your request:

```julia
using EcRequests
request = EcRequest(
   "stream" => "oper",
   "levtype" => "sfc",
   "param" => "165.128/41.128",
   "dataset" => "interim",
   "step" => "0",
   "grid" => "0.75/0.75",
   "time" => "00",
   "date" => "2013-09-01/to/2013-09-30",
   "type" => "an",
   "class" => "ei",
   "target" => "interim_2013-09-01to2013-09-30_00.grib"
)
```

And then run it:
```julia
EcRequests.runmars(request)
```

You can also read a file with the [MARS](https://confluence.ecmwf.int/display/UDOC/MARS+user+documentation) syntax:
```bash
cat > my_request << EOF
retrieve,
   stream=oper,
   levtype=sfc,
   param=165.128/41.128,
   dataset=interim,
   step=0,
   grid=0.75/0.75,
   time=00,
   date=2013-09-01/to/2013-09-30,
   type=an,
   class=ei,
   target="interim_2013-09-01to2013-09-30_00.grib"
EOF
```

```julia
request = EcRequest("my_request")
OrderedCollections.OrderedDict{String, Any} with 11 entries:
  "stream"  => "oper"
  "levtype" => "sfc"
  "param"   => "165.128/41.128"
  "dataset" => "interim"
  "step"    => "0"
  "grid"    => "0.75/0.75"
  "time"    => "00"
  "date"    => "2013-09-01/to/2013-09-30"
  "type"    => "an"
  "class"   => "ei"
  "target"  => "\"interim_2013-09-01to2013-09-30_00.grib\""
```

## Remark
This package has not been developed by ECMWF people. If you're from ECMWF, don't hesitate to contact me and discuss about further improvement!