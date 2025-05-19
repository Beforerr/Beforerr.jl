include("./save.jl")
include("./labels.jl")

const SUPPORTED_POS = [:top, :bottom, :left, :right]
DEFAULT_FORMATS = [:png, :pdf]

function gridposition(ax)
    gc = ax.layoutobservables.gridcontent[]
    gc.parent[gc.span.rows, gc.span.cols]
end

function figuresdir(; name="figures")
    proj_file = Base.current_project()
    isnothing(proj_file) ? name : joinpath(dirname(proj_file), name)
end

figuresdir(args...) = joinpath(figuresdir(), args...)

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

# left, right, bottom, top
function _theme_legend(; padding=(0, 0, 0, 0), margin=(0, 0, 0, 0))
    return Theme(;
        Legend=(
            framevisible=false,
            padding,
            margin,
        )
    )
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
