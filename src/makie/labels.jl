# padding(left, right, bottom, top)
function add_label!(layout, label; position = TopLeft(), font = :bold, halign = :left, valign = nothing, padding = (-5, 0, 5, 0), kwargs...)
    valign = @something valign (position == TopLeft() ? :bottom : :top)
    return Label(
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
function add_labels!(layouts::AbstractArray; labels = 'a':'z', open = "(", close = ")", kw...)
    for (label, layout) in zip(labels, layouts)
        tag = open * label * close
        add_label!(layout, tag; kw...)
    end
    return
end

# https://docs.makie.org/stable/explanations/figure#Retrieving-Objects-From-A-Figure
# Retrieve the leaf nodes (Axis, Axis3, PolarAxis) from layouts
_content(f::Figure) = f.content
_content(gl) = contents(gl)
_full_content(x) = x
_full_content(gl::Union{GridLayout, GridPosition}) = mapreduce(_full_content, vcat, contents(gl); init = [])

"""
Add labels to a figure, automatically searching for blocks to label.

# Notes
- https://github.com/brendanjohnharris/Foresight.jl/blob/main/src/Layouts.jl#L2
"""
function add_labels!(f = current_figure(); allowedblocks = Union{Axis, Axis3, PolarAxis}, kwargs...)
    axs = filter(x -> x isa allowedblocks, _content(f))
    layouts = gridposition.(axs)
    return add_labels!(unique(layouts); kwargs...)
end

function add_topbar!(ax, intervals; color = :grey)
    lims = ax.limits
    hfrac = 0.05

    for (x1, x2) in intervals
        rect = lift(lims) do lim
            yl = lim[2]
            h = hfrac * (yl[2] - yl[1])
            Point2f[(x1, yl[2] - h), (x2, yl[2] - h), (x2, yl[2]), (x1, yl[2])]
        end
        poly!(ax, rect; color, space = :data)
    end
    return ax
end
