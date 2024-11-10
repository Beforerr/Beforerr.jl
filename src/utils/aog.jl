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


"""Add a legend to the figure grid `fg`, with the default legend positioned at the top"""
function pretty_legend!(fg::FigureGrid; position=:top, titleposition=default_titleposition(position), kwargs...)
    legend!(fg; position=position, titleposition=titleposition, kwargs...)
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
