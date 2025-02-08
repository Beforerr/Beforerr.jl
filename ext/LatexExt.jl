module LatexExt
using LaTeXStrings
using Latexify
using Unitful
using UnitfulLatexify
import Latexify: latexify

"""
    latexify(symbols::Pair...; digits=2)

Convert a collection of symbol-value pairs to a LaTeX expression string.
Each pair should be in the form :symbol => value or "custom_latex" => value.

Examples:
```julia
latexify(:B₀ => 5.67, :θ => 0.45)
```
"""
function latexify(pairs::Pair...; digits=2)
    parts = map(pairs) do (sym, val)
        latex_sym = Latexify.latexify(sym; cdot=false)
        if val isa Unitful.Quantity || val isa Unitful.Unit
            val = round(typeof(val), val; digits)
            val_sym = latexify(val)
        else
            val_sym = round(val; digits)
        end
        "$(latex_sym)=$(val_sym)"
    end
    expr = join(parts, ", \\; ")
    return L"%$expr"
end

end