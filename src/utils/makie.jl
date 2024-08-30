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

"""
    pretty_legend!(fig, grid)

Add a legend to the figure
"""
function pretty_legend!(fig, grid)
    legend!(fig[0, 1:end], grid, titleposition=:left, orientation=:horizontal)
end

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


for sym in [:hidexlabel!, :hideylabel!]
    @eval function $sym(ae::AxisEntries; kwargs...)
        axis = ae.axis
        AlgebraOfGraphics.isaxis2d(axis) && $sym(axis; kwargs...)
    end
end