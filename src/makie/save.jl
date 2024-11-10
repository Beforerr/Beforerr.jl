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
    default_kwargs = (; px_per_unit=4)
    kwargs = merge(default_kwargs, kwargs)
    for fmt in formats
        path = joinpath(dir, name * ".$fmt")
        safe_save(path, fig; log=log, force=force, kwargs...)
    end
    return fig
end

easy_save(name; kwargs...) = easy_save(name, current_figure(); kwargs...)