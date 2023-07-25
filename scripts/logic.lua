local EventHandler = require("__core__/lualib/event_handler")


local Logic = {}
Logic.i = 1


function Logic.init()
    for _, player in pairs(game.players) do
        local show_game_time = player.mod_settings.gamestats_show_game_time
        local show_evolution_percentage = player.mod_settings.gamestats_show_evolution_percentage
        local show_online_players_count = player.mod_settings.gamestats_show_online_players_count
        local show_player_deaths_count = player.mod_settings.gamestats_show_player_deaths_count
        local player_deaths_in_right_column = player.mod_settings.gamestats_player_deaths_in_right_column
        local show_killed_biters_count = player.mod_settings.gamestats_show_killed_biters_count
        local show_killed_worms_count = player.mod_settings.gamestats_show_killed_worms_count
        local show_destroyed_nests_count = player.mod_settings.gamestats_show_destroyed_nests_count
        local merge_kills = player.mod_settings.gamestats_merge_kills

        local container = Interface.get_container(player)

        -- if player.
        
    end
end

function Logic.load(event)
end

function Logic.configuration_changed(data)

end

function Logic.setting_changed(event)
    if event.setting_type ~= "runtime-per-user" then
        return
    end

    if not event.player_index then
        return
    end

    local settings = game.players[event.player_index].mod_settings

    -- Тут будет обработка всех изменений в настройках

    if event.setting == "gamestats_player_deaths_in_right_column" then
        -- Значение настройки хранится в поле value
        if settings.gamestats_player_deaths_in_right_column.value then
            -- Менять настройки из кода можно только при
            -- переопределении элемента таблицы player.mod_settings,
            -- а не его значения value
            settings.gamestats_player_deaths_in_right_column = {value = false}
        end
    end
end

function Logic.tick_60(event)
    for _, player in pairs(game.connected_players) do
        Interface.update(player)
    end
end


local event_handlers = {}
event_handlers.on_init = Logic.init
event_handlers.on_load = Logic.load
event_handlers.on_configuration_changed = Logic.configuration_changed
event_handlers.on_nth_tick = {[60] = Logic.tick_60}
event_handlers.events = {
    [defines.events.on_runtime_mod_setting_changed] = Logic.setting_changed
}
EventHandler.add_lib(event_handlers)


return Logic
