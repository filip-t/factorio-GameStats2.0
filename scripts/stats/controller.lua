local self = {
    created = {},
    rebuild = {}
}

function self.on_configuration_changed(data)
    for _, player in pairs(game.players) do
        Stats.ui.is_new = {}
        Stats.ui.remove(player)

        local gui = player.gui.top

        if gui.GameStats__top_frame then
            gui.GameStats__top_frame.destroy()
        end

        if gui.GameStats__container then
            gui.GameStats__container.destroy()
        end

        if gui.mod_gui_top_frame then
            gui = gui.mod_gui_top_frame.mod_gui_inner_frame

            if gui.GameStats__top_frame then
                gui.GameStats__top_frame.destroy()
            end

            if gui.GameStats__container then
                gui.GameStats__container.destroy()
            end
        end

        Stats.ui.update(player)
        Stats.ui.align(player)

        self.update_period(player)
    end
end

function self.on_player_created(event)
    local player = game.players[event.player_index]

    Stats.ui.update(player)
    Stats.ui.align(player)
end

function self.on_player_joined_game(event)
    local player = game.players[event.player_index]
    self.update_period(player)
end

function self.on_nth_tick(event)
    for _, player in pairs(game.connected_players) do
        if self.rebuild[player.index] then
            Stats.ui.remove(player)
            self.rebuild[player.index] = nil
        end

        Stats.ui.update(player)
        Stats.ui.align(player)
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

function self.update_period(player)
    local old_update_period = Settings.get(player.index, Settings.options.update_period) or Settings.update_period_default
    local new_update_period = player.mod_settings.gamestats_update_period.value

    script.on_nth_tick(old_update_period * 60, nil)
    script.on_nth_tick(new_update_period * 60, self.on_nth_tick)

    Settings.set(player.index, Settings.options.update_period, new_update_period)
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
    gamestats_update_period = self.update_period,
    gamestats_show_background = self.show_background,
    gamestats_float_stats = self.float_stats,
    gamestats_align = self.align
}

function self.on_gui_click(event)
    if not event.element or not event.element.valid then
        return
    end

    if event.element.name == Stats.ui.names.settings_button then
        Settings.ui.open(game.players[event.player_index])
    end
end


EventDispatcher.register_event("on_configuration_changed", self.on_configuration_changed)
EventDispatcher.register_event(defines.events.on_player_created, self.on_player_created)
EventDispatcher.register_event(defines.events.on_player_joined_game, self.on_player_joined_game)
EventDispatcher.register_event(defines.events.on_runtime_mod_setting_changed, self.on_runtime_mod_setting_changed)
EventDispatcher.register_event(defines.events.on_gui_click, self.on_gui_click)

script.on_nth_tick(Settings.update_period_default, function(event)
    script.on_nth_tick(Settings.update_period_default, nil)

    for _, player in pairs(game.players) do
        local update_period = player.mod_settings.gamestats_update_period.value
        script.on_nth_tick(update_period*60, self.on_nth_tick)

        Stats.ui.update(player)
        Stats.ui.align(player)
    end
end)

return self