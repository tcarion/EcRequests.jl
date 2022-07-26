using Documenter
using EcRequests

makedocs(
    sitename = "EcRequests",
    format = Documenter.HTML(),
    modules = [EcRequests]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
