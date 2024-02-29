using CairoMakie

function add_label!(layout, label; position=TopLeft())
    Label(layout[1, 1, position], label,
        font=:bold,
        padding = (0, 40, 0, 0),
        halign=:right)
end

function add_labels!(layouts; labels)
    for (label, layout) in zip(labels, layouts)
        add_label!(layout, label)
    end
end