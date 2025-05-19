function add_label!(layout, label; position=TopLeft(), font=:bold, halign=:left, valign=:bottom, padding=(-5, 0, 5, 0), kwargs...)
    Label(
        layout[1, 1, position], label;
        font,
        halign, valign, padding,
        kwargs...
    )
end

"""
Add labels to a grid of layouts

# Notes
- See `tag_facet` in `egg` for reference
"""
function add_labels!(layouts::AbstractArray; labels='a':'z', open="(", close=")")
    for (label, layout) in zip(labels, layouts)
        tag = open * label * close
        add_label!(layout, tag)
    end
end

_content(f) = contents(content(f))
_content(f::Figure) = f.content

"""
Add labels to a figure, automatically searching for blocks to label.

# Notes
- https://github.com/brendanjohnharris/Foresight.jl/blob/main/src/Layouts.jl#L2
"""
function add_labels!(f=current_figure(); allowedblocks=Union{Axis,Axis3,PolarAxis}, kwargs...)
    axs = filter(x -> x isa allowedblocks, _content(f))
    layouts = gridposition.(axs)
    add_labels!(unique(layouts); kwargs...)
end