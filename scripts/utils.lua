local stdutils = require("__core__/lualib/util")


local self = {
    merge = stdutils.merge,
    format_number = stdutils.format_number
}


function self.spell_index(num)
    local last_digit = num % 10

    if last_digit == 1 then
        return 1
    elseif last_digit > 1 and last_digit < 5 then
        return 2
    end

    return 3
end

function self.separate_thousands(number, separator)
    if number < 1000 then
        return number
    end

    local triads = {}

    while true do
        table.insert(triads, 1, string.format("%03d", number % 1000))

        number = math.floor(number / 1000)

        if number < 1000 then
            table.insert(triads, 1, number % 1000)
            break
        end
    end

    return table.concat(triads, separator)
end

function self.is_entity_type(what_type, entity_name)
    local prototype = game.entity_prototypes[entity_name]
    return prototype and prototype.type == what_type
end

function self.is_biter(entity_name)
    return is_entity_type("unit", entity_name)
end

function self.is_spawner(entity_name)
    return is_entity_type("unit-spawner", entity_name)
end

function self.is_worm(entity_name)
    return is_entity_type("turret", entity_name)
end


return self