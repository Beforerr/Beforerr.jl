import AlgebraOfGraphics: FigureGrid

function add_label!(layout, label; position=TopLeft(), font=:bold, halign=:right, kwargs...)
    Label(
        layout[1, 1, position], label;
        font=font,
        padding=(0, 40, 0, 0),
        halign=halign,
        kwargs...
    )
end


"""
add labels to a grid of layouts

# Notes
- See `tag_facet` in `egg` for reference
"""
function add_labels!(layouts; labels=('a':'z'), open="(", close=")")
    for (label, layout) in zip(labels, layouts)
        tag = open * label * close
        add_label!(layout, tag)
    end
end


default_titleposition(position) = position in [:top, :bottom] ? :left : :top

"""
Add a legend to the figure grid `fg`, with the default legend positioned at the top
"""
function pretty_legend!(fg::FigureGrid; position=:top, titleposition=default_titleposition(position), kwargs...)
    legend!(fg; position=position, titleposition=titleposition, kwargs...)
end

"""
Add a legend to the figure
"""
pretty_legend!(fig, grid; kwargs...) = pretty_legend!(FigureGrid(fig, grid); kwargs...)

"""
    easy_save(name[, fig]; formats=[:pdf, :png], dir="figures", log=true)

Save a figure in multiple formats
"""
function easy_save(name, fig; formats=[:pdf, :png], dir="figures", log=true)
    path = joinpath(dir, name)
    mkpath(dirname(path))

    for format in formats
        save("$path.$format", fig; px_per_unit=4)
        log && @info "Saved $(abspath("$path.$format"))"
    end

    return fig
end

easy_save(name; kwargs...) = easy_save(name, current_figure(); kwargs...)


hidexlabel!(la::Axis) = la.xlabelvisible = false
hideylabel!(la::Axis) = la.ylabelvisible = false


"""
Similar to `hideinnerdecorations!` in `AlgebraOfGraphics.jl` but for `FigureGrid`
"""
function hideylabels!(fgs)
    if length(fgs) > 1
        [hideylabel!.(fg) for fg in fgs[2:end]]
    end
end

@kwdef struct PlotOpts
    add_labels = add_labels!
    pretty_legend = pretty_legend!
end

function process_opts!(fg::FigureGrid, axs, opts::PlotOpts)
    opts.add_labels && opts.add_labels(axs)
    opts.pretty_legend && opts.pretty_legend(fg)
end


for sym in [:hidexlabel!, :hideylabel!]
    @eval function $sym(ae::AxisEntries; kwargs...)
        axis = ae.axis
        AlgebraOfGraphics.isaxis2d(axis) && $sym(axis; kwargs...)
    end
end