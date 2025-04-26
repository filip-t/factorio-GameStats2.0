local option_names = {
    "update_period",
    "columns"
}

self = {
    update_period_default = 1,
    options = {}
}

for _, name in pairs(option_names) do
    self.options[name] = name
end

self.align_stats = {
    no = "no",
    left = "left",
    right = "right"
}

self.time_formats = {
    hours = "hours",
    words = "words",
    suffix = "suffix",
    letters = "letters",
    slashes = "slashes"
}

self.number_formats = {
    full = "full",
    round = "round",
    space = "space",
    comma = "comma",
    apostrophe = "apostrophe"
}

self.thousand_separators = {
    space = " ",
    comma = ",",
    apostrophe = "'"
}


function self.get(player_index, name)
    if not global then
        return
    end

    if not global.settings then
        return
    end

    if not global.settings[player_index] then
        return
    end

    return global.settings[player_index][name]
end

function self.set(player_index, name, value)
    if not global then
        global = {}
    end

    if not global.settings then
        global.settings = {}
    end

    if not global.settings[player_index] then
        global.settings[player_index] = {}
    end

    global.settings[player_index][name] = value
end


self.ui = require("__GameStats__/scripts/settings/ui")
self.controller = require("__GameStats__/scripts/settings/controller")

self.controller.init(self)

return self
