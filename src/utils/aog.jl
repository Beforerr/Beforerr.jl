using AlgebraOfGraphics: default_isvertical
using AlgebraOfGraphics: FigureGrid

Base.:*(l::Layer, p::NamedTuple) = l * mapping(; p...)
Base.:*(l::Layer, p::Tuple) = l * mapping(p...)


"""
    cdraw!(f, args...; position=:right, kwargs...)

Like `AlgebraOfGraphics.draw!`, but adds a colorbar.
"""
function cdraw!(f::GridLayout, args...; position=:right, vertical=default_isvertical(position), colorbar=(;), kw...)
    grids = draw!(f[1, 1], args...; kw...)
    guide_pos = guides_position(f, position)
    colorbar!(guide_pos, grids; vertical, colorbar...)
    return grids
end

cdraw!(f::Union{GridPosition,GridSubposition}, args...; kw...) = cdraw!(GridLayout(f), args...; kw...)

fn(v::Pair) = v[1], v[2]
fn(v) = v, identity

"""
    sdraw!(layout, layer, facet=:v, dim=:col; scales=scales(), kwargs...)

Draw a figure grid with facets by a column or row.
"""
function sdraw!(layout, layer::Layer, facet; dim=:col, scales=scales(), kwargs...)
    df = layer.data.columns
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
        Label(label_pos, facet_func(v), tellwidth=(dim == :col))
        grids
    end
end

"""Add a legend to the figure grid `fg`, with the default legend positioned at the top"""
function pretty_legend!(fg::FigureGrid; position=:top, kwargs...)
    titleposition = position in (:top, :bottom) ? :left : :top
    legend!(fg; position, titleposition, kwargs...)
end

"""Add a legend to the figure"""
pretty_legend!(fig, grid; kwargs...) = pretty_legend!(FigureGrid(fig, grid); kwargs...)


for sym in [:hidexlabel!, :hideylabel!]
    @eval function $sym(ae::AxisEntries; kwargs...)
        axis = ae.axis
        AlgebraOfGraphics.isaxis2d(axis) && $sym(axis; kwargs...)
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
    process_opts!(axs, opts.axs_opts)
end
