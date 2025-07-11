using AlgebraOfGraphics: Layers
using AlgebraOfGraphics: default_isvertical, AxisEntries
using AlgebraOfGraphics: FigureGrid
using DataFrames, DataFramesMeta

Base.:*(l::Union{Layer, Layers}, p::NamedTuple) = l * mapping(; p...)
Base.:*(l::Union{Layer, Layers}, p::Tuple) = l * mapping(p...)


"""
    cdraw!(f, args...; position=:right, kwargs...)

Like `AlgebraOfGraphics.draw!`, but adds a colorbar.
"""
function cdraw!(f::GridLayout, args...; position = :right, vertical = default_isvertical(position), colorbar = (;), kw...)
    grids = draw!(f[1, 1], args...; kw...)
    guide_pos = guides_position(f, position)
    colorbar!(guide_pos, grids; vertical, colorbar...)
    return grids
end

cdraw!(f::Union{GridPosition, GridSubposition}, args...; kw...) = cdraw!(GridLayout(f), args...; kw...)

fn(v::Pair) = v[1], v[2]
fn(v) = v, string
vals(df::DataFrames.DataFrameColumns, s) = unique(df[s]) |> sort
vals(df::DataFrame, s) = unique(df[!, s]) |> sort

"""
    sdraw!(layout, layer, facet; dim=:col; scales=scales(), kwargs...)

Draw a figure grid with facets by a column or row.
"""
function sdraw!(layout, layer::Layer, facet; dim = :col, scales = scales(), add_cb = false, kwargs...)
    df = getfield(layer.data.columns, :df)
    facet_sym, facet_func = fn(facet)
    vs = vals(df, facet_sym)  # Get unique values
    fgs = if dim == :col
        [layout[1, i] for i in 1:length(vs)]
    else
        [layout[i, 1] for i in 1:length(vs)]
    end
    return map(zip(fgs, vs)) do (fg, v)
        df_s = @subset(df, $facet_sym .== v)
        plt = layer * data(df_s)
        grids = draw!(fg, plt, scales; kwargs...)
        label_pos = dim == :col ? fg[0, :] : fg[:, 0]
        Label(label_pos, facet_func(v), tellwidth = false)
        # only add last colorbar label
        colorbar_kwargs = Dict()
        v == vs[end] || push!(colorbar_kwargs, :label => "")
        add_cb && colorbar!(fg[:, 0], grids; colorbar_kwargs...)
        grids
    end
end

"""Add a legend to the figure grid `fg`, with the default legend positioned at the top"""
function pretty_legend!(fg::FigureGrid; position = :top, kwargs...)
    titleposition = position in (:top, :bottom) ? :left : :top
    return legend!(fg; position, titleposition, kwargs...)
end

"""Add a legend to the figure"""
pretty_legend!(fig, grid; kwargs...) = pretty_legend!(FigureGrid(fig, grid); kwargs...)


for sym in [:hidexlabel!, :hideylabel!]
    @eval function $sym(ae::AxisEntries; kwargs...)
        axis = ae.axis
        return AlgebraOfGraphics.isaxis2d(axis) && $sym(axis; kwargs...)
    end
end

@kwdef struct FigureGridOpts
    pretty_legend = pretty_legend!
end

@kwdef struct PlotOpts
    axs_opts = AxsOpts()
    fg_opts = FigureGridOpts()
end

function process_opts!(fg::FigureGrid, axs, opts::PlotOpts)
    process_opts!(fg, opts.fg_opts)
    return process_opts!(axs, opts.axs_opts)
end
