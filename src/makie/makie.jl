include("./save.jl")

DEFAULT_FORMATS = [:png, :pdf]

function figuresdir(; name="figures")
    proj_file = Base.current_project()
    isnothing(proj_file) ? name : joinpath(dirname(proj_file), name)
end

figuresdir(args...) = joinpath(figuresdir(), args...)

function add_label!(layout, label; position=TopLeft(), font=:bold, halign=:left, valign=:bottom, padding=(0, 0, 0, -30), kwargs...)
    Label(
        layout[1, 1, position], label;
        font,
        halign, valign, padding,
        kwargs...
    )
end

# -----
# Theme
# -----
const HWRATIO = 0.68

"""1 point in CairoMakie is equal to 1/72 inch."""
inch2point(x) = floor(Int, 72x)

"""Convert figure size from inches to points."""
function figsize(width; height=missing, hwratio=HWRATIO)
    height = ismissing(height) ? width * hwratio : height
    return (inch2point(width), inch2point(height))
end

function theme_pub(; width=6.75, hwratio=HWRATIO, axis=(;), kwargs...)
    default_axis_theme = (;)
    axis_theme = merge(default_axis_theme, axis)

    theme_args = (
        figure_padding=0,
        size=figsize(width; hwratio),
        Axis=axis_theme,
    )
    Theme(; theme_args...)
end

"""
add labels to a grid of layouts

# Notes
- See `tag_facet` in `egg` for reference
"""
function add_labels!(layouts; labels='a':'z', open="(", close=")")
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

@kwdef struct AxsOpts
    add_labels = add_labels!
end

function process_opts!(x, opts)
    for name in propertynames(opts)
        f = getfield(opts, name)
        isa(f, Function) && f(x)
    end
end
