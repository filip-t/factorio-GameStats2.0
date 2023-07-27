local ModGui = require("__core__/lualib/mod-gui")

local Interface = {
    top_frame_name = "GameStats__top_frame",
    inner_frame_name = "GameStats__inner_frame",
    container_name = "GameStats__container",
    left_column_name = "GameStats__left_column",
    right_column_name = "GameStats__right_column",
    game_time_name = "GameStats__game_time",
    evolution_percentage_name = "GameStats__evolution_percentage",
    online_players_count_name = "GameStats__online_players_count",
    dead_players_count_name = "GameStats__dead_players_count",
    killed_biters_count_name = "GameStats__killed_biters_count",
    killed_worms_count_name = "GameStats__killed_worms_count",
    destroyed_nests_count_name = "GameStats__destroyed_nests_count",
    killed_enemy_count_name = "GameStats__killed_enemy_count"
}
Interface.do_align = {}

local self = Interface


local function get_button_flow(player)
    if not player then
        return
    end

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

    if player.mod_settings.gamestats_show_separately.value then
        if player.mod_settings.gamestats_show_background.value then
            button_flow = get_button_flow(player)
        else
            button_flow = player.gui.top
        end
    else
        button_flow = ModGui.get_button_flow(player)
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

    local parent, container
    
    if player.mod_settings.gamestats_show_separately.value then
        parent = player.gui.top

        if player.mod_settings.gamestats_show_background.value then
            container = parent[self.top_frame_name]
        else
            container = parent[self.container_name]
        end
    else
        parent = ModGui.get_button_flow(player)
        container = parent[self.container_name]
    end

    if not container then
        return
    end


    local container_index = container.get_index_in_parent()
    local children_size = #parent.children

    -- game.print({"", parent.name, " / ", container.name})

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


    local game_seconds = math.floor(game.ticks_played / 60)
    local hours = 0
    local minutes = 0
    local seconds = 0

    hours = math.floor(game_seconds / 3600)
    game_seconds = game_seconds % 3600
    minutes = math.floor(game_seconds / 60)
    seconds = game_seconds % 60

    local game_time = string.format("%d:%02d:%02d", hours, minutes, seconds)

    -- this nonsense is because string.format(%.4f) is not safe in MP across platforms, but integer math is
    local evolution_percentage = game.forces.enemy.evolution_factor * 100
    local whole_number = math.floor(evolution_percentage)

    evolution_percentage = string.format("%d.%04d", whole_number, math.floor((evolution_percentage - whole_number) * 10000))

    local online_players_count = #game.connected_players
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


    local settings = player.mod_settings

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

    
    if settings.gamestats_merge_kills.value then
        local killed_enemy_count_element = right_column[self.killed_enemy_count_name]
        local killed_enemy_count_caption = {
            "interface.killed_enemy_count",
            killed_biters_count + killed_worms_count + destroyed_nests_count
        }

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

function Interface.remove(player)
    if player.gui.top[self.top_frame_name] then
        player.gui.top[self.top_frame_name].destroy()
    elseif player.gui.top[self.container_name] then
        player.gui.top[self.container_name].destroy()
    else
        local button_flow = ModGui.get_button_flow(player)

        if button_flow[self.container_name] then
            button_flow[self.container_name].destroy()
        end
    end
end


return Interface