module Beforerr

using AlgebraOfGraphics, Makie
using Match

export add_labels!, hideylabels!, pretty_legend!
export AxsOpts, FigureGridOpts, PlotOpts, process_opts!
export figuresdir, easy_save
export cdraw!

include("makie/makie.jl")
include("utils/aog.jl")

end
