function add_label!(layout, label; position=TopLeft())
    Label(layout[1, 1, position], label,
        font=:bold,
        padding = (0, 40, 0, 0),
        halign=:right)
end


"""
add labels to a grid of layouts

# Notes
- See `tag_facet` in `egg` for reference
"""
function add_labels!(layouts; labels = ('a':'z'), open = "(", close = ")")
    for (label, layout) in zip(labels, layouts)
        tag = open * label * close
        add_label!(layout, tag)
    end
end

function pretty_legend!(fig, grid)
    legend!(fig[0, 1:end], grid, titleposition=:left, orientation=:horizontal)
end

function easy_save(name, fig; dir="figures")
    path = "$dir/$name"
    mkpath(dir)

    save("$path.png", fig, px_per_unit=4)
    save("$path.pdf", fig)
    
    # log the path saved
    @info "Saved $(abspath(path)).png"
    fig
end

function easy_save(name; dir="figures")
    fig = current_figure()
    easy_save(name, fig, dir=dir)
end