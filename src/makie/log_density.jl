using AlgebraOfGraphics: automatic, transformation, set, nested_extrema_finite, pdf
using AlgebraOfGraphics: ProcessedLayer, ProcessedLayers
using AlgebraOfGraphics: valid_options, defaultdatalimits, applydatalimits
import AlgebraOfGraphics as AoG
using InverseFunctions

Base.@kwdef struct DensityAnalysis{D, K, B, F}
    datalimits::D = automatic
    npoints::Int = 200
    kernel::K = automatic
    bandwidth::B = automatic
    direction::Union{Makie.Automatic, Symbol} = automatic
    transform::F = identity
end

function _density(vs::Tuple; datalimits, npoints, transform, kwargs...)
    vs′ = map(v -> transform.(v), vs)
    k = AoG._kde(vs′; kwargs...)
    intervals = applydatalimits(datalimits, vs)
    rgs′ = map(intervals) do (min, max)
        return range(transform(min), transform(max); length = npoints)
    end
    res′ = pdf(k, rgs′...)
    rgs = map(rg -> (inverse(transform)).(rg), rgs′)
    return (rgs..., res′)
end

function (d::DensityAnalysis)(input::ProcessedLayer)
    datalimits = d.datalimits === automatic ? defaultdatalimits(input.positional) : d.datalimits
    options = valid_options(; datalimits, d.npoints, d.kernel, d.bandwidth, d.transform)
    output = map(input) do p, n
        return _density(Tuple(p); pairs(n)..., pairs(options)...), (;)
    end
    N = length(input.positional)
    labels = set(input.labels, N + 1 => "pdf")
    plottypes = [LinesFill, Heatmap, Volume]
    default_plottype = plottypes[N]
    plottype = Makie.plottype(input.plottype, default_plottype)
    return ProcessedLayer(output; plottype, labels)
end

"""
    density(; datalimits=automatic, kernel=automatic, bandwidth=automatic, npoints=200, direction=automatic)

Fit a kernel density estimation of `data`.

Here, `datalimits` specifies the range for which the density should be calculated
(it defaults to the extrema of the whole data).
The keyword argument `datalimits` can be a tuple of two values, e.g. `datalimits=(0, 10)`,
or a function to be applied group by group, e.g. `datalimits=extrema`.
The keyword arguments `kernel` and `bandwidth` are forwarded to `KernelDensity.kde`.
`npoints` is the number of points used by Makie to draw the line

Weighted data is supported via the keyword `weights` (passed to `mapping`).

For 1D, returns two layers, a `Band` with label `:area` and a `Lines` with label `:line`
which you can separately style using [`subvisual`](@ref). The direction may be changed to
vertical via `direction = :y`.

For 2D, returns a `Heatmap` and for 3D a `Volume` layer.
"""
density(; options...) = transformation(DensityAnalysis(; options...))
