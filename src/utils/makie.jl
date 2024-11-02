import AlgebraOfGraphics: FigureGrid

DEFAULT_FORMATS = [:png, :pdf]

function figuresdir(; name = "figures")
    proj_file = Base.current_project()
    isnothing(proj_file) ? name : joinpath(dirname(proj_file), name)
end

figuresdir(args...) = joinpath(figuresdir(), args...)

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

function safe_save(file, io; log=true, force=false, kwargs...)
    mkpath(dirname(file))
    if !force && isfile(file)
        log && @info "File $(abspath(file)) already exists. Skipping..."
    else
        save(file, io; kwargs...)
        log && @info "Saved $(abspath(file))"
    end
end

"""
    easy_save(name[, fig]; formats=[:pdf, :png], dir=figuresdir(), log=true, force=false, kwargs...)

Save a figure in multiple formats
"""
function easy_save(name, fig; formats=DEFAULT_FORMATS, dir=figuresdir(), log=true, force=false, kwargs...)
    default_kwargs = (;px_per_unit=4)
    kwargs = merge(default_kwargs, kwargs)
    for fmt in formats
        path = joinpath(dir, name * ".$fmt")
        safe_save(path, fig; log=log, force=force, kwargs...)
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

@kwdef struct AxsOpts
    add_labels = add_labels!
end

@kwdef struct FigureGridOpts
    pretty_legend = pretty_legend!
end

@kwdef struct PlotOpts
    axs_opts = AxsOpts()
    fg_opts = FigureGridOpts()
end

function process_opts!(x, opts)
    for name in propertynames(opts)
        f = getfield(opts, name)
        isa(f, Function) && f(x)
    end
end

function process_opts!(fg::FigureGrid, axs, opts::PlotOpts)
    process_opts!(fg, opts.fg_opts)
    process_opts!(axs, opts.axs_opts)
end


for sym in [:hidexlabel!, :hideylabel!]
    @eval function $sym(ae::AxisEntries; kwargs...)
        axis = ae.axis
        AlgebraOfGraphics.isaxis2d(axis) && $sym(axis; kwargs...)
    end
end