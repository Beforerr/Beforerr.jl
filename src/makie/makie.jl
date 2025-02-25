include("./save.jl")

const SUPPORTED_POS = [:top, :bottom, :left, :right]
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
    # basesize=10
    legend_theme = (
        framevisible=false,
        padding=(0, 0, 0, 0),
        margin=(0, 0, 0, 0),
        # rowgap=-10,
        # colgap=4,
    )

    default_axis_theme = (
        xgridvisible=false,
        ygridvisible=false,
        xlabelfont=:bold,
        ylabelfont=:bold,
        # xlabelsize=basesize,
        # ylabelsize=basesize,
        # xticklabelsize=basesize * 0.8,
        # yticklabelsize=basesize * 0.8,
    )
    axis_theme = merge(default_axis_theme, axis)

    Series = (; color=Makie.wong_colors())
    Lines = (; linewidth=2)
    theme_args = (
        figure_padding=0,
        size=figsize(width; hwratio),
        Axis=axis_theme,
        Legend=legend_theme,
        Series,
        Lines,
        kwargs...
    )
    Theme(; theme_args...)
end

"""
Add labels to a grid of layouts

# Notes
- See `tag_facet` in `egg` for reference
"""
function add_labels!(layouts; labels='a':'z', open="(", close=")")
    for (label, layout) in zip(labels, layouts)
        tag = open * label * close
        add_label!(layout, tag)
    end
end

"""
Add labels to a figure, automatically searching for blocks to label.

# Notes
- https://github.com/brendanjohnharris/Foresight.jl/blob/main/src/Layouts.jl#L2
"""
function add_labels!(; f=current_figure(), allowedblocks=Union{Axis,Axis3,PolarAxis}, kwargs...)
    axs = filter(x -> x isa allowedblocks, f.content)
    add_labels!(axs; kwargs...)
end

# -----
# Position
# -----
"""
    guides_position(f, position)

Return the position of the guides (like colorbar) for the given `position` in the `f`.
"""
function guides_position(f, position)
    @match Symbol(position) begin
        :bottom => f[end+1, :]
        :top => f[0, :]
        :right => f[:, end+1]
        :left => f[:, 0]
        _ => throw(ArgumentError("Legend position $position ∉ $SUPPORTED_POS"))
    end
end


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
