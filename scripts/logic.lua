local EventHandler = require("__core__/lualib/event_handler")


local Logic = {}
Logic.rebuild = {}


function Logic.player_created(event)
    Interface.do_align[event.player_index] = true
    Interface.update(game.players[event.player_index])
end

function Logic.player_joined_game(event)
    Interface.remove_gui(game.players[event.player_index])
    Interface.do_align[event.player_index] = true
    Interface.update(game.players[event.player_index])
end

function Logic.tick_60(event)
    for _, player in pairs(game.connected_players) do
        if Logic.rebuild[player.index] then
            Interface.remove_gui(player)
            Interface.do_align[player.index] = true
            Logic.rebuild[player.index] = nil
        end

        Interface.update(player)
    end
end

function Logic.setting_changed(event)
    if event.setting_type ~= "runtime-per-user" then
        return
    end

    if not event.player_index then
        return
    end

    if not Logic.handlers[event.setting] then
        return
    end

    Logic.handlers[event.setting](game.players[event.player_index])
end


function Logic.show_game_time(player)
    local settings = player.mod_settings

    if settings.gamestats_show_game_time.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)
        Interface.remove_element(container, Interface.left_column_name, Interface.game_time_name)
    end
end

function Logic.show_evolution_percentage(player)
    local settings = player.mod_settings

    if settings.gamestats_show_evolution_percentage.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)
        Interface.remove_element(container, Interface.left_column_name, Interface.evolution_percentage_name)
    end
end

function Logic.show_online_players_count(player)
    if not game.is_multiplayer() then
        return
    end

    local settings = player.mod_settings

    if settings.gamestats_show_online_players_count.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)
        Interface.remove_element(container, Interface.left_column_name, Interface.online_players_count_name)
    end
end

function Logic.show_pollution(player)
    local settings = player.mod_settings

    if settings.gamestats_show_pollution.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)
        Interface.remove_element(container, Interface.left_column_name, Interface.pollution_name)
    end
end

function Logic.show_dead_players_count(player)
    local settings = player.mod_settings

    if settings.gamestats_show_dead_players_count.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)

        if settings.gamestats_dead_players_count_column.value == "left" then
            Interface.remove_element(container, Interface.left_column_name, Interface.dead_players_count_name)
        elseif settings.gamestats_dead_players_count_column.value == "right" then
            Interface.remove_element(container, Interface.right_column_name, Interface.dead_players_count_name)
        end
    end
end

function Logic.dead_players_count_column(player)
    local settings = player.mod_settings

    if not settings.gamestats_show_dead_players_count.value then
        return
    end

    if settings.gamestats_merge_kills.value
    and settings.gamestats_dead_players_count_column.value ~= "left"
    then
        settings.gamestats_dead_players_count_column = {value = "left"}
        return
    end

    local container = Interface.get_container(player)

    if settings.gamestats_dead_players_count_column.value == "left" then
        Interface.remove_element(container, Interface.right_column_name, Interface.dead_players_count_name)
    elseif settings.gamestats_dead_players_count_column.value == "right" then
        Interface.remove_element(container, Interface.left_column_name, Interface.dead_players_count_name)
    end

    Logic.rebuild[player.index] = true
end

function Logic.show_killed_biters_count(player)
    local settings = player.mod_settings

    if settings.gamestats_show_killed_biters_count.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)
        Interface.remove_element(container, Interface.right_column_name, Interface.killed_biters_count_name)
    end
end

function Logic.show_killed_worms_count(player)
    local settings = player.mod_settings

    if settings.gamestats_show_killed_worms_count.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)
        Interface.remove_element(container, Interface.right_column_name, Interface.killed_worms_count_name)
    end
end

function Logic.show_destroyed_nests_count(player)
    local settings = player.mod_settings

    if settings.gamestats_show_destroyed_nests_count.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)
        Interface.remove_element(container, Interface.right_column_name, Interface.destroyed_nests_count_name)
    end
end

function Logic.merge_kills(player)
    local settings = player.mod_settings
    local container = Interface.get_container(player)

    if settings.gamestats_merge_kills.value then
        Interface.remove_element(container, Interface.right_column_name, Interface.killed_biters_count_name)
        Interface.remove_element(container, Interface.right_column_name, Interface.killed_worms_count_name)
        Interface.remove_element(container, Interface.right_column_name, Interface.destroyed_nests_count_name)

        if settings.gamestats_dead_players_count_column.value == "left" then
            Interface.remove_element(container, Interface.left_column_name, Interface.dead_players_count_name)
        end
    else
        Interface.remove_element(container, Interface.right_column_name, Interface.killed_enemy_count_name)

        if settings.gamestats_dead_players_count_column.value == "left" then
            Interface.remove_element(container, Interface.right_column_name, Interface.dead_players_count_name)
        end
    end

    Logic.rebuild[player.index] = true
end

function Logic.show_background(player)
    Interface.remove_gui(player)
    Interface.do_align[player.index] = true
    Logic.rebuild[player.index] = true
end

function Logic.always_on_left(player)
    local settings = player.mod_settings

    if settings.gamestats_always_on_left.value then
        if settings.gamestats_always_on_right.value then
            settings.gamestats_always_on_right = {value = false}
        end

        Interface.do_align[player.index] = true
        Interface.align(player)
    end
end

function Logic.always_on_right(player)
    local settings = player.mod_settings

    if settings.gamestats_always_on_right.value then
        if settings.gamestats_always_on_left.value then
            settings.gamestats_always_on_left = {value = false}
        end

        Interface.do_align[player.index] = true
        Interface.align(player)
    end
end


Logic.handlers = {
    gamestats_show_game_time = Logic.show_game_time,
    gamestats_show_evolution_percentage = Logic.show_evolution_percentage,
    gamestats_show_online_players_count = Logic.show_online_players_count,
    gamestats_show_pollution = Logic.show_pollution,
    gamestats_show_dead_players_count = Logic.show_dead_players_count,
    gamestats_dead_players_count_column = Logic.dead_players_count_column,
    gamestats_show_killed_biters_count = Logic.show_killed_biters_count,
    gamestats_show_killed_worms_count = Logic.show_killed_worms_count,
    gamestats_show_destroyed_nests_count = Logic.show_destroyed_nests_count,
    gamestats_merge_kills = Logic.merge_kills,
    gamestats_show_background = Logic.show_background,
    gamestats_always_on_left = Logic.always_on_left,
    gamestats_always_on_right = Logic.always_on_right
}


local event_handlers = {}
event_handlers.on_nth_tick = {[60] = Logic.tick_60}
event_handlers.events = {
    [defines.events.on_player_created] = Logic.player_created,
    [defines.events.on_player_joined_game] = Logic.player_joined_game,
    [defines.events.on_runtime_mod_setting_changed] = Logic.setting_changed
}
EventHandler.add_lib(event_handlers)


return Logic
