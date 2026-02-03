module LatexExt
using LaTeXStrings
using Latexify
using Unitful
import Latexify: latexify
import Beforerr: latexxx

"""
    latexxx(symbols::Pair...; digits=2)

Convert a collection of symbol-value pairs to a LaTeX expression string.
Each pair should be in the form :symbol => value or "custom_latex" => value.

Examples:
```julia
latexxx(:B₀ => 5.67, :θ => 0.45)
```
"""
function latexxx(pairs::Pair...; digits = 2, sign = "=", delim = ", ")
    parts = map(pairs) do (sym, val)
        latex_sym = Latexify.latexify(sym; cdot = false)
        if val isa Unitful.Quantity || val isa Unitful.Unit
            val = round(typeof(val), val; sigdigits = digits)
            val_sym = latexify(val)
        else
            val_sym = val
        end
        "$(latex_sym)$sign$(latexify(val_sym; fmt = FancyNumberFormatter(digits)))"
    end
    expr = join(parts, delim)
    return L"%$expr"
end

latexxx(nt; kw...) = latexxx(pairs(nt)...; kw...)

end
