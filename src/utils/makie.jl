function add_label!(layout, label; position=TopLeft())
    Label(layout[1, 1, position], label,
        font=:bold,
        padding=(0, 40, 0, 0),
        halign=:right)
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

function pretty_legend!(fig, grid)
    legend!(fig[0, 1:end], grid, titleposition=:left, orientation=:horizontal)
end

"""
    easy_save(name[, fig]; formats=[:pdf, :png], dir="figures", log=true)

Save a figure in multiple formats
"""
function easy_save(name, fig; formats=[:pdf, :png], dir="figures", log=true)
    path = joinpath(dir, name) |> mkpath

    for format in formats
        save("$path.$format", fig; px_per_unit=4)
        log && @info "Saved $(abspath("$path.$format"))"
    end

    return fig
end

easy_save(name; kwargs...) = easy_save(name, current_figure(); kwargs...)


function hideylabels(la::Axis)
    la.ylabelvisible = false
end

function hideylabels!(fgs)
    if length(fgs) > 1
        [hideylabels.(fg) for fg in fgs[2:end]]
    end
end

for sym in [:hideylabels,]
    @eval function $sym(ae::AxisEntries; kwargs...)
        axis = ae.axis
        AlgebraOfGraphics.isaxis2d(axis) && $sym(axis; kwargs...)
    end
end