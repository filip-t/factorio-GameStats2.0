self = {
    show_background = "show_background",
    float_stats = "float_stats",
    align_stats = "align_stats",
    time_format = "time_format",
    number_format = "number_format",
    thousand_separator = "thousand_separator",
    columns = "columns"
}

self.show_background = {
    no = false,
    yes = true
}
self.show_background_deafult = self.show_background.yes

self.float_stats = {
    no = false,
    yes = true
}
self.float_stats.default = self.float_stats.no

self.align_stats = {
    no = "no",
    left = "left",
    right = "right"
}
self.float_stats_default = self.float_stats.left

self.time_formats = {
    hours = "hours",
    words = "words",
    slashes = "slashes"
}
self.time_formats_default = self.time_formats.hours

self.number_formats = {
    full = "full",
    human_readable = "human_readable"
}
self.time_formats_default = self.time_formats.full

self.thousand_separators = {
    no = "",
    space = " ",
    comma = ",",
    apostrophe = "'"
}
self.thousand_separators_default = self.thousand_separators.no


self.get = function(player_index, name)
    if not global.settings then
        return
    end

    if not global.settings[player_index] then
        return
    end
    
    return global.settings[player_index][name]
end

self.set = function(player_index, name, value)
    if not global.settings then
        global.settings = {}
    end

    if not global.settings[player_index] then
        global.settings[player_index] = {}
    end
    
    return global.settings[player_index][name] = value
end


return self