Base.:*(l::Layer, p::NamedTuple) = l * mapping(; p...)
Base.:*(l::Layer, p::Tuple) = l * mapping(p...)

"""
    cdraw!(f, args...; position=:right, kwargs...)

Like `AlgebraOfGraphics.draw!`, but adds a colorbar.
"""
function cdraw!(f::GridLayout, args...; position=:right, kw...)
    grids = draw!(f[1, 1], args...; kw...)
    guide_pos = f[:, end+1]
    colorbar!(guide_pos, grids)
    return grids
end

cdraw!(f::Union{GridPosition, GridSubposition}, args...; kw...) = cdraw!(GridLayout(f), args...; kw...)