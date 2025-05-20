local self = {}

function self.on_configuration_changed(data)
    if data.mod_changes.GameStats20 and data.mod_changes.GameStats20.old_version == "1.0.3" then
        for _, player in pairs(game.players) do
            local gui = player.gui.top

            if gui.GameStats20__top_frame then
                gui.GameStats20__top_frame.destroy()
            end

            if gui.GameStats20__container then
                gui.GameStats20__container.destroy()
            end

            if gui.mod_gui_top_frame then
                gui = gui.mod_gui_top_frame.mod_gui_inner_frame

                if gui.GameStats20__top_frame then
                    gui.GameStats20__top_frame.destroy()
                end

                if gui.GameStats20__container then
                    gui.GameStats20__container.destroy()
                end
            end

            Stats.ui.remove(player)
            Stats.ui.update(player)
            Stats.ui.align(player)
        end
    end
end

function self.on_player_joined_game(event)
    local player = game.players[event.player_index]

    storage.gamestats20 = storage.gamestats20 or {}
    storage.gamestats20[player.index] = storage.gamestats20[player.index] or {}
    storage.gamestats20[player.index].old_position = storage.gamestats20[player.index].old_position or player.physical_position
    storage.gamestats20[player.index].distance_foot = storage.gamestats20[player.index].distance_foot or 0
    storage.gamestats20[player.index].distance_car = storage.gamestats20[player.index].distance_car or 0
    storage.gamestats20[player.index].distance_tank = storage.gamestats20[player.index].distance_tank or 0
    storage.gamestats20[player.index].distance_train = storage.gamestats20[player.index].distance_train or 0
    storage.gamestats20[player.index].distance_spider = storage.gamestats20[player.index].distance_spider or 0

    Stats.ui.update(player)
    Stats.ui.align(player)
end

function self.on_nth_tick(event)
    local seconds = event.tick / event.nth_tick

    for _, player in pairs(game.connected_players) do
        local update_period = player.mod_settings.gamestats20_update_period.value

        if seconds % update_period == 0 then
            Stats.ui.update(player)
            Stats.ui.align(player)
        end
    end
end

function self.on_runtime_mod_setting_changed(event)
    if not event
    or event.setting_type ~= "runtime-per-user"
    or not event.player_index
    then
        return
    end

    if self.handlers[event.setting] then
        self.handlers[event.setting](game.players[event.player_index])
    end
end

function self.show_background(player)
    Stats.ui.remove(player)
    Stats.ui.update(player)
    Stats.ui.align(player)
end

function self.float_stats(player)
    Stats.ui.remove(player)
    Stats.ui.update(player)
    Stats.ui.align(player)
end

function self.align(player)
    Stats.ui.align(player)
end

self.handlers = {
    gamestats20_show_background = self.show_background,
    gamestats20_float_stats = self.float_stats,
    gamestats20_align = self.align
}

function self.on_gui_click(event)
    if not event.element or not event.element.valid then
        return
    end

    if event.element.name == Stats.ui.names.settings_button then
        Settings.ui.open(game.players[event.player_index])
    end
end

function self.on_player_changed_position(event)
    local player = game.get_player(event.player_index)
    local old_position = storage.gamestats20[player.index].old_position
    local new_position = player.physical_position
    local distance = math.sqrt((old_position.x - new_position.x) ^ 2 + (old_position.y - new_position.y) ^ 2)
    if distance > 0 and distance < 5 then
        if player.physical_vehicle then
            local v_type = player.physical_vehicle.type
            local v_name = player.physical_vehicle.name
            if v_type == "car" then
                if v_name == "car" then
                    storage.gamestats20[player.index].distance_car = storage.gamestats20[player.index].distance_car + distance
                elseif v_name == "tank" then
                    storage.gamestats20[player.index].distance_tank = storage.gamestats20[player.index].distance_tank + distance
                end
            elseif v_type == "locomotive" or v_type == "cargo-wagon" or v_type == "fluid-wagon" or v_type == "artillery-wagon" then
                storage.gamestats20[player.index].distance_train = storage.gamestats20[player.index].distance_train + distance
            elseif v_type == "spider-vehicle" then
                storage.gamestats20[player.index].distance_spider = storage.gamestats20[player.index].distance_spider + distance
            end
        else
            storage.gamestats20[player.index].distance_foot = storage.gamestats20[player.index].distance_foot + distance
        end
    end
    storage.gamestats20[player.index].old_position = new_position
end


EventDispatcher.register_event("on_configuration_changed", self.on_configuration_changed)
EventDispatcher.register_event(defines.events.on_player_joined_game, self.on_player_joined_game)
EventDispatcher.register_event(defines.events.on_runtime_mod_setting_changed, self.on_runtime_mod_setting_changed)
EventDispatcher.register_event(defines.events.on_gui_click, self.on_gui_click)
EventDispatcher.register_event(defines.events.on_player_changed_position, self.on_player_changed_position)

script.on_nth_tick(60, self.on_nth_tick)


return self
