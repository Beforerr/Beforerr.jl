module Beforerr

using AlgebraOfGraphics, Makie
using Match

export add_labels!, hideylabels!, pretty_legend!, align_ylabels!
export add_topbar!
export AxsOpts, FigureGridOpts, PlotOpts, process_opts!
export figuresdir, easy_save, theme_pub
export cdraw!, sdraw!
export lstring, latexxx

function latexxx end

include("makie/makie.jl")
include("utils/aog.jl")
include("utils/units.jl")
include("stats.jl")

const EASY_SAVE_FORCE = Ref{Bool}(false)

end
