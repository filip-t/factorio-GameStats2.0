local Interface = {
    top_frame_name = "GameStats__top_frame",
    inner_frame_name = "GameStats__inner_frame",
    container_name = "GameStats__container",
    left_column_name = "GameStats__left_column",
    right_column_name = "GameStats__right_column",
    game_time_name = "GameStats__game_time",
    evolution_percentage_name = "GameStats__evolution_percentage",
    online_players_count_name = "GameStats__online_players_count",
    pollution_name = "GameStats__pollution",
    dead_players_count_name = "GameStats__dead_players_count",
    killed_biters_count_name = "GameStats__killed_biters_count",
    killed_worms_count_name = "GameStats__killed_worms_count",
    destroyed_nests_count_name = "GameStats__destroyed_nests_count",
    killed_enemy_count_name = "GameStats__killed_enemy_count"
}
Interface.do_align = {}

local self = Interface
local thousand_separators = {
    space = " ",
    comma = ","
}


local function orfo_index(num, vars)
    local last_digit = num % 10

    if last_digit == 1 then
        return 1
    elseif last_digit >=2 and last_digit <= 4 then
        return 2
    end

    return 3
end

local function separate_thousands(number, separator)
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

local function get_frame(player)
    local outer_frame = player.gui.top[self.top_frame_name] or player.gui.top.add {
        type="frame", name=self.top_frame_name, direction="horizontal", style="quick_bar_window_frame"
    }
    return outer_frame[self.inner_frame_name] or outer_frame.add {
        type="frame", name=self.inner_frame_name, direction="horizontal", style="mod_gui_inside_deep_frame"
    }
end

local function is_entity_type(what_type, entity_name)
    local prototype = game.entity_prototypes[entity_name]
    return prototype and prototype.type == what_type
end

local function is_biter(entity_name)
    return is_entity_type("unit", entity_name)
end

local function is_spawner(entity_name)
    return is_entity_type("unit-spawner", entity_name)
end

local function is_worm(entity_name)
    return is_entity_type("turret", entity_name)
end


function Interface.get_container(player)
    if not player then
        return
    end

    local button_flow

    if player.mod_settings.gamestats_show_background.value then
        button_flow = get_frame(player)
    else
        button_flow = player.gui.top
    end

    local container = button_flow[self.container_name] or button_flow.add {
        type="flow", name=self.container_name, direction="horizontal"
    }

    self.align(player)

    return container
end

function Interface.align(player)
    if not player then
        return
    end

    if not self.do_align[player.index] then
        return
    end

    self.do_align[player.index] = nil


    local on_left = player.mod_settings.gamestats_always_on_left.value
    local on_right = player.mod_settings.gamestats_always_on_right.value

    if not on_left and not on_right then
        return
    end

    local parent = player.gui.top
    local container

    if player.mod_settings.gamestats_show_background.value then
        container = parent[self.top_frame_name]
    else
        container = parent[self.container_name]
    end

    if not container then
        return
    end


    local container_index = container.get_index_in_parent()
    local children_size = #parent.children

    if on_left then
        if container_index ~= 1 then
            parent.swap_children(container_index, 1)
        end
    elseif on_right then
        if container_index ~= children_size then
            parent.swap_children(container_index, children_size)
        end
    end
end

function Interface.update(player)
    if not player then
        return
    end

    local container = self.get_container(player)

    if not container then
        return
    end

    local settings = player.mod_settings

    local game_seconds = math.floor(game.ticks_played / 60)

    -- For testing hours > 0
    -- game_seconds = game_seconds + 16 * 3600

    -- For testing days > 0
    -- game_seconds = game_seconds + (128 * 24 + 16) * 3600

    local days = 0
    local hours = 0
    local minutes = 0
    local seconds = 0

    local time_format = settings.gamestats_time_format.value

    if time_format ~= "hours" then
        days = math.floor(game_seconds / (3600*24))
        game_seconds = game_seconds % (3600*24)
    end

    hours = math.floor(game_seconds / 3600)
    game_seconds = game_seconds % 3600
    minutes = math.floor(game_seconds / 60)
    seconds = game_seconds % 60

    local game_time

    if time_format ~= "hours" then
        if time_format == "words" then
            game_time = {""}

            if days > 0 then
                table.insert(game_time, {"interface.orfo_days_"..orfo_index(days), days})
                table.insert(game_time, " ")
            end

            if hours > 0 then
                table.insert(game_time, {"interface.orfo_hours_"..orfo_index(hours), hours})
                table.insert(game_time, " ")
            end

            table.insert(game_time, {"interface.orfo_minutes_"..orfo_index(minutes), minutes})
        elseif time_format == "slashes" then
            game_time = string.format("%d/%02d/%02d", days, hours, minutes)
        else
            -- Fallback for unusual setting value. IDK how it's possible, but...
            game_time = "WRONG FORMAT"
        end
    else
        game_time = string.format("%d:%02d:%02d", hours, minutes, seconds)
    end

    -- This nonsense is because string.format(%.4f) is not safe in MP across platforms, but integer math is
    local evolution_percentage = game.forces.enemy.evolution_factor * 100
    local whole_number = math.floor(evolution_percentage)

    evolution_percentage = string.format("%d.%04d", whole_number, math.floor((evolution_percentage - whole_number) * 10000))

    local online_players_count = #game.connected_players

    local pollution = 0

    if player.character then
        local surface = player.character.surface
        local position = player.character.position

        pollution = surface.get_pollution(position)
        pollution = math.floor(pollution * 100) / 100
    end

    local dead_players_count = player.force.kill_count_statistics.output_counts["character"] or 0

    local killed_biters_count = 0
    local killed_worms_count = 0
    local destroyed_nests_count = 0

    for entity_name, kill_count in pairs(player.force.kill_count_statistics.input_counts) do
        if is_biter(entity_name) then
            killed_biters_count = killed_biters_count + kill_count
        elseif is_worm(entity_name) then
            killed_worms_count = killed_worms_count + kill_count
        elseif is_spawner(entity_name) then
            destroyed_nests_count = destroyed_nests_count + kill_count
        end
    end

    -- Random numbers for testing

    -- killed_biters_count = killed_biters_count + 342000
    -- killed_worms_count = killed_worms_count + 56000
    -- destroyed_nests_count = destroyed_nests_count + 3000

    -- killed_biters_count = killed_biters_count + 256000000
    -- killed_worms_count = killed_worms_count + 17000000
    -- destroyed_nests_count = destroyed_nests_count + 5000000

    local left_column = container[self.left_column_name] or container.add {
        type = "flow",
        name = self.left_column_name,
        direction = "vertical"
    }
    left_column.style.left_margin = 5
    left_column.style.right_margin = 15

    local right_column = container[self.right_column_name] or container.add {
        type = "flow",
        name = self.right_column_name,
        direction = "vertical"
    }
    right_column.style.right_margin = 5


    if settings.gamestats_show_game_time.value then
        local game_time_element = left_column[self.game_time_name]
        local game_time_value = {"interface.game_time", game_time}

        if not game_time_element then
            left_column.add {
                type = "label",
                name = self.game_time_name,
                caption = game_time_value
            }
        else
            game_time_element.caption = game_time_value
        end
    end

    if settings.gamestats_show_evolution_percentage.value then
        local evolution_percentage_element = left_column[self.evolution_percentage_name]
        local evolution_percentage_value = {"interface.evolution_percentage", evolution_percentage}

        if not evolution_percentage_element then
            left_column.add {
                type = "label",
                name = self.evolution_percentage_name,
                caption = evolution_percentage_value
            }
        else
            evolution_percentage_element.caption = evolution_percentage_value
        end
    end

    if settings.gamestats_show_pollution.value then
        local pollution_element = left_column[self.pollution_name]
        local pollution_caption = {"interface.pollution", pollution}

        if not pollution_element then
            left_column.add {
                type = "label",
                name = self.pollution_name,
                caption = pollution_caption
            }
        else
            pollution_element.caption = pollution_caption
        end
    end

    local thousand_separator = thousand_separators[settings.gamestats_thousand_separator.value]

    if settings.gamestats_merge_kills.value then
        local killed_sum = killed_biters_count + killed_worms_count + destroyed_nests_count

        if thousand_separator then
            killed_sum = separate_thousands(killed_sum, thousand_separator)
        end

        local killed_enemy_count_element = right_column[self.killed_enemy_count_name]
        local killed_enemy_count_caption = {"interface.killed_enemy_count", killed_sum}

        if not killed_enemy_count_element then
            right_column.add {
                type = "label",
                name = self.killed_enemy_count_name,
                caption = killed_enemy_count_caption
            }
        else
            killed_enemy_count_element.caption = killed_enemy_count_caption
        end
    else
        if settings.gamestats_show_killed_biters_count.value then
            if thousand_separator then
                killed_biters_count = separate_thousands(killed_biters_count, thousand_separator)
            end

            local killed_biters_count_element = right_column[self.killed_biters_count_name]
            local killed_biters_count_caption = {"interface.killed_biters_count", killed_biters_count}

            if not killed_biters_count_element then
                right_column.add {
                    type = "label",
                    name = self.killed_biters_count_name,
                    caption = killed_biters_count_caption
                }
            else
                killed_biters_count_element.caption = killed_biters_count_caption
            end
        end

        if settings.gamestats_show_killed_worms_count.value then
            if thousand_separator then
                killed_worms_count = separate_thousands(killed_worms_count, thousand_separator)
            end

            local killed_worms_count_element = right_column[self.killed_worms_count_name]
            local killed_worms_count_caption = {"interface.killed_worms_count", killed_worms_count}

            if not killed_worms_count_element then
                right_column.add {
                    type = "label",
                    name = self.killed_worms_count_name,
                    caption = killed_worms_count_caption
                }
            else
                killed_worms_count_element.caption = killed_worms_count_caption
            end
        end

        if settings.gamestats_show_destroyed_nests_count.value then
            if thousand_separator then
                destroyed_nests_count = separate_thousands(destroyed_nests_count, thousand_separator)
            end

            local destroyed_nests_count_element = right_column[self.destroyed_nests_count_name]
            local destroyed_nests_count_caption = {"interface.destroyed_nests_count", destroyed_nests_count}

            if not destroyed_nests_count_element then
                right_column.add {
                    type = "label",
                    name = self.destroyed_nests_count_name,
                    caption = destroyed_nests_count_caption
                }
            else
                destroyed_nests_count_element.caption = destroyed_nests_count_caption
            end
        end
    end

    if game.is_multiplayer() and settings.gamestats_show_online_players_count.value then
        local online_players_count_element = left_column[self.online_players_count_name]
        local online_players_count_caption = {"interface.online_players_count", online_players_count}

        if not online_players_count_element then
            left_column.add {
                type = "label",
                name = self.online_players_count_name,
                caption = online_players_count_caption
            }
        else
            online_players_count_element.caption = online_players_count_caption
        end
    end

    if settings.gamestats_show_dead_players_count.value then
        local column

        if settings.gamestats_merge_kills.value
        or settings.gamestats_dead_players_count_in_right_column.value
        then
            column = right_column
        else
            column = left_column
        end

        local dead_players_count_element = column[self.dead_players_count_name]
        local dead_players_count_caption = {"interface.dead_players_count", dead_players_count}

        if not dead_players_count_element then
            column.add {
                type = "label",
                name = self.dead_players_count_name,
                caption = dead_players_count_caption
            }
        else
            dead_players_count_element.caption = dead_players_count_caption
        end
    end
end

function Interface.remove_element(container, column_name, element_name)
    if not container[column_name] then
        return
    end

    if container[column_name][element_name] then
        container[column_name][element_name].destroy()
    end
end

function Interface.remove_gui(player)
    if player.gui.top[self.top_frame_name] then
        player.gui.top[self.top_frame_name].destroy()
    elseif player.gui.top[self.container_name] then
        player.gui.top[self.container_name].destroy()
    end
end


return Interface