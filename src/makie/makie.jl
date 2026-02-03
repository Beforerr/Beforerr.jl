include("./save.jl")
include("./labels.jl")
include("./FHistAog.jl")
include("./log_density.jl")
using .FHistAog
export fhist
export delete_legends!

const SUPPORTED_POS = [:top, :bottom, :left, :right]
DEFAULT_FORMATS = [:png, :pdf]

function gridposition(ax)
    gc = ax.layoutobservables.gridcontent[]
    return gc.parent[gc.span.rows, gc.span.cols]
end

function figuresdir(; name = "figures")
    proj_file = Base.current_project()
    return isnothing(proj_file) ? name : joinpath(dirname(proj_file), name)
end

figuresdir(args...) = joinpath(figuresdir(), args...)

# -----
# Theme
# -----
const HWRATIO = 0.68

"""1 point in CairoMakie is equal to 1/72 inch."""
inch2point(x) = floor(Int, 72x)

"""Convert figure size from inches to points."""
function figsize(width; height = missing, hwratio = HWRATIO)
    height = ismissing(height) ? width * hwratio : height
    return (inch2point(width), inch2point(height))
end

# left, right, bottom, top
function _theme_legend(; padding = (0, 0, 0, 0), margin = (0, 0, 0, 0))
    return Theme(;
        Legend = (
            framevisible = false,
            padding,
            margin,
        )
    )
end

function theme_pub(; width = 6.75, hwratio = HWRATIO, axis = (;), kwargs...)
    # basesize=10
    legend_theme = (
        framevisible = false,
        padding = (0, 0, 0, 0),
        margin = (0, 0, 0, 0),
        # rowgap=-10,
        # colgap=4,
    )

    default_axis_theme = (
        xgridvisible = false,
        ygridvisible = false,
        xlabelfont = :bold,
        ylabelfont = :bold,
        # xlabelsize=basesize,
        # ylabelsize=basesize,
        # xticklabelsize=basesize * 0.8,
        # yticklabelsize=basesize * 0.8,
    )
    axis_theme = merge(default_axis_theme, axis)

    Series = (; color = Makie.wong_colors())
    Lines = (; linewidth = 2)
    theme_args = (
        figure_padding = 0,
        size = figsize(width; hwratio),
        Axis = axis_theme,
        Legend = legend_theme,
        Series,
        Lines,
        kwargs...,
    )
    return Theme(; theme_args...)
end

# -----
# Position
# -----
"""
    guides_position(f, position)

Return the position of the guides (like colorbar) for the given `position` in the `f`.
"""
function guides_position(f, position)
    return @match Symbol(position) begin
        :bottom => f[end + 1, :]
        :top => f[0, :]
        :right => f[:, end + 1]
        :left => f[:, 0]
        _ => throw(ArgumentError("Legend position $position ∉ $SUPPORTED_POS"))
    end
end

function align_ylabels!(axes)
    yspace = maximum(tight_yticklabel_spacing!, axes)
    for ax in axes
        ax.yticklabelspace = yspace
    end
    return
end


hidexlabel!(la::Axis) = la.xlabelvisible = false
hideylabel!(la::Axis) = la.ylabelvisible = false

"""
Similar to `hideinnerdecorations!` in `AlgebraOfGraphics.jl` but for `FigureGrid`
"""
function hideylabels!(fgs)
    return if length(fgs) > 1
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
    return
end

contains_legend(::Any) = false
contains_legend(gl::GridLayout) = length(contents(gl)) == 1 && contents(gl)[1] isa Legend

is_empty_grid(gl::GridLayout) = length(gl.content) == 0
is_empty_grid(::Any) = false

function clean_empty_grids!(fg)
    for gl in contents(fg)
        for gc in gl.content
            is_empty_grid(gc.content) && Makie.GridLayoutBase.remove_from_gridlayout!(gc)
        end
    end
    return fg
end

function delete_legends!(fg)
    entries = _content(fg)
    for entry in entries
        entry isa Legend && delete!(entry)
    end
    clean_empty_grids!(fg)
    return fg
end
