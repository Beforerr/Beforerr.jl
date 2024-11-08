using AlgebraOfGraphics: default_isvertical

const SUPPORTED_POS = [:top, :bottom, :left, :right]

Base.:*(l::Layer, p::NamedTuple) = l * mapping(; p...)
Base.:*(l::Layer, p::Tuple) = l * mapping(p...)

"""
    guides_position(f, position)

Return the position of the guides for the given `position` in the `f`.
"""
function guides_position(f, position)
    position = Symbol(position)
    position ∉ SUPPORTED_POS && throw(ArgumentError("Legend position $position ∉ $SUPPORTED_POS"))

    @match position begin
        :bottom => f[end+1, :]
        :top => f[0, :]
        :right => f[:, end+1]
        :left => f[:, 0]
    end
end

"""
    cdraw!(f, args...; position=:right, kwargs...)

Like `AlgebraOfGraphics.draw!`, but adds a colorbar.
"""
function cdraw!(f::GridLayout, args...; position=:right, vertical=default_isvertical(position), colorbar = (;), kw...)
    grids = draw!(f[1, 1], args...; kw...)
    guide_pos = guides_position(f, position)
    colorbar!(guide_pos, grids; vertical, colorbar...)
    return grids
end

cdraw!(f::Union{GridPosition,GridSubposition}, args...; kw...) = cdraw!(GridLayout(f), args...; kw...)