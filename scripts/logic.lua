local EventHandler = require("__core__/lualib/event_handler")


local Logic = {}
Logic.rebuild = {}


function Logic.configuration_changed(data)
    -- ?
end

function Logic.player_created(event)
    Interface.do_align[event.player_index] = true
    Interface.update(game.players[event.player_index])
end

function Logic.player_joined_game(event)
    Interface.remove(game.players[event.player_index])
    Interface.do_align[event.player_index] = true
    Interface.update(game.players[event.player_index]) 
end

function Logic.tick_60(event)
    for _, player in pairs(game.connected_players) do
        if Logic.rebuild[player.index] then
            Interface.remove(player)
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

    local player = game.players[event.player_index]
    Logic.handlers[event.setting](player)
end


function Logic.show_game_time(player)
    game.print("show_game_time")
    local settings = player.mod_settings

    if settings.gamestats_show_game_time.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)

        if container[Interface.left_column_name][Interface.game_time_name] then
            container[Interface.left_column_name][Interface.game_time_name].destroy()
        end
    end
end

function Logic.show_evolution_percentage(player)
    game.print("show_evolution_percentage")
    local settings = player.mod_settings

    if settings.gamestats_show_evolution_percentage.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)

        if container[Interface.left_column_name][Interface.evolution_percentage_name] then
            container[Interface.left_column_name][Interface.evolution_percentage_name].destroy()
        end
    end
end

function Logic.show_online_players_count(player)
    game.print("show_online_players_count")
    if not game.is_multiplayer() then
        return
    end

    local settings = player.mod_settings

    if settings.gamestats_show_online_players_count.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)

        if container[Interface.left_column_name][Interface.online_players_count_name] then
            container[Interface.left_column_name][Interface.online_players_count_name].destroy()
        end
    end
end

function Logic.show_dead_players_count(player)
    game.print("show_dead_players_count")
    local settings = player.mod_settings

    if settings.gamestats_show_dead_players_count.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)

        if container[Interface.left_column_name][Interface.dead_players_count_name] then
            container[Interface.left_column_name][Interface.dead_players_count_name].destroy()
        end

        if container[Interface.right_column_name][Interface.dead_players_count_name] then
            container[Interface.right_column_name][Interface.dead_players_count_name].destroy()
        end
    end
end

function Logic.dead_players_count_in_right_column(player)
    game.print("dead_players_count_in_right_column")
    if not game.is_multiplayer() then
        return
    end

    local settings = player.mod_settings

    if settings.gamestats_show_dead_players_count.value then
        Logic.rebuild[player.index] = true
    else
        return
    end

    local container = Interface.get_container(player)

    if settings.gamestats_dead_players_count_in_right_column.value
    and container[Interface.left_column_name][Interface.dead_players_count_name]
    then
        container[Interface.left_column_name][Interface.dead_players_count_name].destroy()
    elseif not settings.gamestats_dead_players_count_in_right_column.value
    and container[Interface.right_column_name][Interface.dead_players_count_name]
    then
        container[Interface.right_column_name][Interface.dead_players_count_name].destroy()
    end
end

function Logic.show_killed_biters_count(player)
    game.print("show_killed_biters_count")
    local settings = player.mod_settings

    if settings.gamestats_show_killed_biters_count.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)

        if container[Interface.right_column_name][Interface.killed_biters_count_name] then
            container[Interface.right_column_name][Interface.killed_biters_count_name].destroy()
        end
    end
end

function Logic.show_killed_worms_count(player)
    game.print("show_killed_worms_count")
    local settings = player.mod_settings

    if settings.gamestats_show_killed_worms_count.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)

        if container[Interface.right_column_name][Interface.killed_worms_count_name] then
            container[Interface.right_column_name][Interface.killed_worms_count_name].destroy()
        end
    end
end

function Logic.show_destroyed_nests_count(player)
    game.print("show_destroyed_nests_count")
    local settings = player.mod_settings

    if settings.gamestats_show_destroyed_nests_count.value then
        Logic.rebuild[player.index] = true
    else
        local container = Interface.get_container(player)

        if container[Interface.right_column_name][Interface.destroyed_nests_count_name] then
            container[Interface.right_column_name][Interface.destroyed_nests_count_name].destroy()
        end
    end
end

function Logic.merge_kills(player)
    game.print("merge_kills")
    local settings = player.mod_settings
    local container = Interface.get_container(player)

    Logic.rebuild[player.index] = true

    if settings.gamestats_merge_kills.value then
        if container[Interface.right_column_name][Interface.killed_biters_count_name] then
            container[Interface.right_column_name][Interface.killed_biters_count_name].destroy()
        end

        if container[Interface.right_column_name][Interface.killed_worms_count_name] then
            container[Interface.right_column_name][Interface.killed_worms_count_name].destroy()
        end

        if container[Interface.right_column_name][Interface.destroyed_nests_count_name] then
            container[Interface.right_column_name][Interface.destroyed_nests_count_name].destroy()
        end

        if game.is_multiplayer()
        and not settings.gamestats_dead_players_count_in_right_column.value
        and container[Interface.left_column_name][Interface.dead_players_count_name]
        then
            container[Interface.left_column_name][Interface.dead_players_count_name].destroy()
        end
    else
        if container[Interface.right_column_name][Interface.killed_enemy_count_name] then
            container[Interface.right_column_name][Interface.killed_enemy_count_name].destroy()
        end

        if game.is_multiplayer()
        and not settings.gamestats_dead_players_count_in_right_column.value
        and container[Interface.right_column_name][Interface.dead_players_count_name]
        then
            container[Interface.right_column_name][Interface.dead_players_count_name].destroy()
        end
    end
end

function Logic.show_separately(player)
    game.print("show_separately")
    local settings = player.mod_settings

    Logic.rebuild[player.index] = true
    Interface.do_align[player.index] = true
    Interface.remove(player)
end

function Logic.show_background(player)
    game.print("show_background")

    if not player.mod_settings.gamestats_show_separately.value then
        return
    end

    Interface.remove(player)
    Interface.do_align[player.index] = true
    Logic.rebuild[player.index] = true
end

function Logic.always_on_left(player)
    game.print("always_on_left")
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
    game.print("always_on_right")
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
    gamestats_show_dead_players_count = Logic.show_dead_players_count,
    gamestats_dead_players_count_in_right_column = Logic.dead_players_count_in_right_column,
    gamestats_show_killed_biters_count = Logic.show_killed_biters_count,
    gamestats_show_killed_worms_count = Logic.show_killed_worms_count,
    gamestats_show_destroyed_nests_count = Logic.show_destroyed_nests_count,
    gamestats_merge_kills = Logic.merge_kills,
    gamestats_show_separately = Logic.show_separately,
    gamestats_show_background = Logic.show_background,
    gamestats_always_on_left = Logic.always_on_left,
    gamestats_always_on_right = Logic.always_on_right
}


local event_handlers = {}
event_handlers.on_configuration_changed = Logic.configuration_changed
event_handlers.on_nth_tick = {[60] = Logic.tick_60}
event_handlers.events = {
    [defines.events.on_player_created] = Logic.player_created,
    [defines.events.on_player_joined_game] = Logic.player_joined_game,
    [defines.events.on_runtime_mod_setting_changed] = Logic.setting_changed
}
EventHandler.add_lib(event_handlers)


return Logic
