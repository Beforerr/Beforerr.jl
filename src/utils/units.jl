superscript2number(s) = replace(s,
    "⁰" => "0", "¹" => "1", "²" => "2", "³" => "3", "⁴" => "4",
    "⁵" => "5", "⁶" => "6", "⁷" => "7", "⁸" => "8", "⁹" => "9",
    "⁻" => "-"
)

latexify_superscript(s) = "^{" * superscript2number(s) * "}"

"""
    lstring(u)

convert unit into latex string

It will add "\\mathrm" around text
"""
function lstring(u; mathrm=true)
    # Convert unit to string
    str = string(u)

    # Replace superscript numbers with LaTeX power notation
    str = replace(str, r"([⁰¹²³⁴⁵⁶⁷⁸⁹⁻]+)" => latexify_superscript)

    # Split by spaces (which separate multiplication)
    parts = split(str, " ")

    # Wrap each part in \mathrm
    if mathrm
        parts = map(parts) do p
            if contains(p, "^")
                base, power = split(p, "^")
                "\\mathrm{" * base * "}" * "^" * power
            else
                "\\mathrm{" * p * "}"
            end
        end
    end

    # Join with \cdot
    return join(parts, "\\cdot ")
end