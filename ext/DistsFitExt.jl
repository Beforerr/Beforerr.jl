module DistsFitExt

import Beforerr: DistsFit
using FHist
using Distributions
using Makie
import Makie.SpecApi as S

"""Use regex to remove content within curly braces including the braces"""
format(d::Distribution) = replace(repr(d), r"\{[^}]+\}" => "")

function Makie.convert_arguments(::Type{<:AbstractPlot}, obj::DistsFit)
    plot_specs = PlotSpec[]
    data, dists, step = obj.data, obj.dists, obj.step

    binedges = 0:step:maximum(data)
    h = Hist1D(data; binedges=binedges) |> normalize
    push!(plot_specs, S.Errorbars(h; whiskerwidth=6, color=:black))

    foreach(dists) do dist
        d = fit(dist, data)
        x = bincenters(h)
        y = pdf(d, x)

        x_mean = mean(d)
        label = format(d)
        push!(plot_specs, S.Lines(x, y; linewidth=2, label))
        push!(plot_specs, S.VLines(x_mean; linestyle=:dash))
    end
    return plot_specs
end

end
