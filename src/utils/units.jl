"""
    lstring(u)

convert unit into latex string

It will add "\\mathrm" around text
"""
function lstring(u; mathrm=true)
    # Convert unit to string
    str = string(u)

    # Replace superscript numbers with LaTeX power notation
    str = replace(str, r"([⁰¹²³⁴⁵⁶⁷⁸⁹⁻]+)" => s -> "^{" * replace(s,
                                                       "⁰" => "0", "¹" => "1", "²" => "2", "³" => "3", "⁴" => "4",
                                                       "⁵" => "5", "⁶" => "6", "⁷" => "7", "⁸" => "8", "⁹" => "9",
                                                       "⁻" => "-") * "}")

    # Split by spaces (which separate multiplication)
    parts = split(str, " ")

    # Wrap each part in \mathrm
    if mathrm
        parts = ["\\mathrm{" * replace(p, "^" => "}^") for p in parts]
    end

    # Join with \cdot
    return join(parts, "\\cdot ")
end