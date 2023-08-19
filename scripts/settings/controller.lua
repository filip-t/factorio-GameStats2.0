local util = require("__core__/lualib/util")



local on_gui_click_handlers = {}



local function on_gui_opened(event)
    if not event.element or not event.element.valid then
        return
    end

    if event.element.name ~= Settings.ui.names.window then
        return
    end

    local player = game.players[event.player_index]
    local window = event.element
    local content_flow = window[Settings.ui.names.content]
    local columns_list = content_flow[Settings.ui.names.columns_flow][Settings.ui.names.columns]
    local stats_list = content_flow[Settings.ui.names.stats_flow][Settings.ui.names.stats]
    local columns = Settings.get(player.index, Settings.options.columns) or Stats.default_columns
    local current_columns = util.table.deepcopy(columns)
    local stats = util.table.deepcopy(Stats.stats)
    local available_stats = {}
    local column_indices = {}

    for index, column in pairs(current_columns) do
        table.insert(column_indices, index)

        for _, stat in pairs(column) do
            stats[stat] = nil
        end
    end

    for _, stat in pairs(stats) do
        table.insert(available_stats, stat)
    end

    window.tags = {columns=current_columns}
    columns_list.tags = {indices=column_indices}
    stats_list.tags = {available_stats=available_stats}

    Settings.ui.update_columns(player)
    Settings.ui.update_current_column_stats(player)
    Settings.ui.update_available_stats(player)
end

local function on_gui_closed(event)
    if not event.element or not event.element.valid then
        return
    end

    if event.element.name == Settings.ui.names.window then
        Settings.ui.close(game.players[event.player_index])
    end
end

local function on_gui_checked_state_changed(event)
    if not event.element or not event.element.valid then
        return
    end

    if event.element.name == Settings.ui.names.show_all_checkbox then
        Settings.ui.update_available_stats(game.players[event.player_index])
    end
end

local function on_gui_selection_state_changed(event)
    if not event.element or not event.element.valid then
        return
    end

    if event.element.name == Settings.ui.names.columns then
        Settings.ui.update_current_column_stats(game.players[event.player_index])
    end
end

local function on_gui_click(event)
    if not event.element or not event.element.valid then
        return
    end

    local player = game.players[event.player_index]

    if on_gui_click_handlers[event.element.name] then
        on_gui_click_handlers[event.element.name](player)
    end
end


local function close_click(player)
    Settings.ui.close(player)
end

local function column_up_click(player)
    local window = player.gui.screen[Settings.ui.names.window]
    local content_flow = window[Settings.ui.names.content]
    local columns_list = content_flow[Settings.ui.names.columns_flow][Settings.ui.names.columns]

    if #columns_list.items == 0 then
        return
    end

    local selected_column_index = columns_list.selected_index

    if selected_column_index == 0 or selected_column_index == 1 then
        return
    end

    local new_index = selected_column_index - 1

    local columns = window.tags.columns
    local temp_column = columns[selected_column_index]
    table.remove(columns, selected_column_index)
    table.insert(columns, new_index, temp_column)
    window.tags = {columns=columns}

    local indices = columns_list.tags.indices
    local temp_index = indices[selected_column_index]
    table.remove(indices, selected_column_index)
    table.insert(indices, new_index, temp_index)
    columns_list.tags = {indices=indices}

    Settings.ui.update_columns(player, new_index)
end

local function column_add_click(player)
    local window = player.gui.screen[Settings.ui.names.window]
    local content_flow = window[Settings.ui.names.content]
    local columns_list = content_flow[Settings.ui.names.columns_flow][Settings.ui.names.columns]
    local columns_indices = columns_list.tags.indices
    local columns = window.tags.columns

    table.insert(columns, {})
    window.tags = {columns=columns}

    table.insert(columns_indices, #columns)
    columns_list.tags = {indices=columns_indices}

    Settings.ui.update_columns(player, #columns)
    Settings.ui.update_current_column_stats(player)
end

local function column_delete_click(player)
    local window = player.gui.screen[Settings.ui.names.window]
    local content_flow = window[Settings.ui.names.content]
    local columns_list = content_flow[Settings.ui.names.columns_flow][Settings.ui.names.columns]

    if #columns_list.items == 0 then
        return
    end

    local selected_column_index = columns_list.selected_index

    if selected_column_index == 0 then
        return
    end

    local columns_indices = columns_list.tags.indices
    table.remove(columns_indices, selected_column_index)
    columns_list.tags = {indices=columns_indices}

    local columns = window.tags.columns
    local selected_column = columns[selected_column_index]
    local stats_list = content_flow[Settings.ui.names.stats_flow][Settings.ui.names.stats]
    local available_stats = stats_list.tags.available_stats

    if #columns > 1 then
        for _, stat in pairs(selected_column) do
            table.insert(available_stats, stat)
        end

        stats_list.tags = {available_stats=available_stats}
    else
        stats_list.tags = {available_stats=Stats.stat_names}
    end

    table.remove(columns, selected_column_index)
    window.tags = {columns=columns}

    selected_column_index = selected_column_index - 1

    if selected_column_index == 0 then
        selected_column_index = 1
    end

    Settings.ui.update_columns(player, selected_column_index)
    Settings.ui.update_current_column_stats(player)

    local show_all = window[Settings.ui.names.options][Settings.ui.names.show_all_checkbox]

    if not show_all.state then
        Settings.ui.update_available_stats(player, stats_list.selected_index)
    end
end

local function column_down_click(player)
    local window = player.gui.screen[Settings.ui.names.window]
    local content_flow = window[Settings.ui.names.content]
    local columns_list = content_flow[Settings.ui.names.columns_flow][Settings.ui.names.columns]

    if #columns_list.items == 0 then
        return
    end

    local selected_column_index = columns_list.selected_index

    if selected_column_index == 0 or selected_column_index == #columns_list.items then
        return
    end

    local new_index = selected_column_index + 1

    local indices = columns_list.tags.indices
    local temp_index = indices[selected_column_index]
    table.remove(indices, selected_column_index)
    table.insert(indices, new_index, temp_index)
    columns_list.tags = {indices=indices}

    local columns = window.tags.columns
    local temp_column = columns[selected_column_index]
    table.remove(columns, selected_column_index)
    table.insert(columns, new_index, temp_column)
    window.tags = {columns=columns}

    Settings.ui.update_columns(player, new_index)
end

local function stat_up_click(player)
    local window = player.gui.screen[Settings.ui.names.window]
    local content_flow = window[Settings.ui.names.content]
    local stats_list = content_flow[Settings.ui.names.current_column_flow][Settings.ui.names.current_column]
    local selected_index = stats_list.selected_index

    if selected_index == 0 or selected_index == 1 then
        return
    end

    local columns_list = content_flow[Settings.ui.names.columns_flow][Settings.ui.names.columns]
    local columns = window.tags.columns
    local current_column_stats = columns[columns_list.selected_index]
    local new_index = selected_index - 1
    local temp_stat = current_column_stats[selected_index]

    table.remove(current_column_stats, selected_index)
    table.insert(current_column_stats, new_index, temp_stat)
    window.tags = {columns=columns}

    Settings.ui.update_current_column_stats(player, new_index)
end

local function stat_add_click(player)
    local window = player.gui.screen[Settings.ui.names.window]
    local content_flow = window[Settings.ui.names.content]
    local stats_list = content_flow[Settings.ui.names.stats_flow][Settings.ui.names.stats]

    if #stats_list.items == 0 then
        return
    end

    local selected_stat_index = stats_list.selected_index

    if selected_stat_index == 0 then
        return
    end

    local columns_list = content_flow[Settings.ui.names.columns_flow][Settings.ui.names.columns]

    if #columns_list.items == 0 then
        return
    end

    local selected_column_index = columns_list.selected_index

    if selected_column_index == 0 then
        return
    end

    local show_all = window[Settings.ui.names.options][Settings.ui.names.show_all_checkbox]
    local available_stats = stats_list.tags.available_stats
    local selected_stat_name

    if show_all.state then
        selected_stat_name = Stats.stat_names[selected_stat_index]
    else
        if #available_stats == 0 then
            return
        end

        selected_stat_name = available_stats[selected_stat_index]
    end

    local columns = window.tags.columns
    local current_column_stats = columns[selected_column_index]

    if show_all.state then
        for _, stat in pairs(current_column_stats) do
            if stat == selected_stat_name then
                return
            end
        end
    end

    table.insert(current_column_stats, selected_stat_name)

    for index, stat in pairs(available_stats) do
        if stat == selected_stat_name then
            table.remove(available_stats, index)
            break
        end
    end

    stats_list.tags = {available_stats=available_stats}

    if show_all.state then
        for column_index, column in pairs(columns) do
            if column_index == selected_column_index then
                goto next_column
            end

            for stat_index, stat in pairs(column) do
                if stat == selected_stat_name then
                    table.remove(column, stat_index)
                    goto break_all
                end
            end

            ::next_column::
        end

        ::break_all::
    end

    window.tags = {columns=columns}

    Settings.ui.update_current_column_stats(player, #current_column_stats)

    if not show_all.state then
        selected_stat_index = selected_stat_index - 1

        if selected_stat_index == 0 then
            selected_stat_index = 1
        end

        Settings.ui.update_available_stats(player, selected_stat_index)
    end
end

local function stat_delete_click(player)
    local window = player.gui.screen[Settings.ui.names.window]
    local content_flow = window[Settings.ui.names.content]
    local current_column_stats_list = content_flow[Settings.ui.names.current_column_flow][Settings.ui.names.current_column]

    if #current_column_stats_list.items == 0 then
        return
    end

    local selected_stat_index = current_column_stats_list.selected_index

    if selected_stat_index == 0 then
        return
    end

    local columns_list = content_flow[Settings.ui.names.columns_flow][Settings.ui.names.columns]

    if #columns_list.items == 0 then
        return
    end

    local selected_column_index = columns_list.selected_index

    if selected_column_index == 0 then
        return
    end

    local columns = window.tags.columns
    local selected_column = columns[selected_column_index]
    local selected_stat_name = selected_column[selected_stat_index]
    table.remove(selected_column, selected_stat_index)
    window.tags = {columns=columns}

    local stats_list = content_flow[Settings.ui.names.stats_flow][Settings.ui.names.stats]
    local available_stats = stats_list.tags.available_stats
    table.insert(available_stats, selected_stat_name)
    stats_list.tags = {available_stats=available_stats}

    selected_stat_index = selected_stat_index -1

    if selected_stat_index == 0 then
        selected_stat_index = 1
    end

    Settings.ui.update_current_column_stats(player, selected_stat_index)

    local show_all = window[Settings.ui.names.options][Settings.ui.names.show_all_checkbox]

    if show_all.state then
        for stat_index, stat in pairs(Stats.stat_names) do
            if stat == selected_stat_name then
                Settings.ui.update_available_stats(player, stat_index)
                break
            end
        end
    else
        Settings.ui.update_available_stats(player, #available_stats)
    end
end

local function stat_down_click(player)
    local window = player.gui.screen[Settings.ui.names.window]
    local content_flow = window[Settings.ui.names.content]
    local stats_list = content_flow[Settings.ui.names.current_column_flow][Settings.ui.names.current_column]
    local selected_index = stats_list.selected_index

    if selected_index == 0 or selected_index == #stats_list.items then
        return
    end

    local columns_list = content_flow[Settings.ui.names.columns_flow][Settings.ui.names.columns]
    local columns = window.tags.columns
    local current_column_stats = columns[columns_list.selected_index]
    local new_index = selected_index + 1
    local temp_stat = current_column_stats[selected_index]

    table.remove(current_column_stats, selected_index)
    table.insert(current_column_stats, new_index, temp_stat)
    window.tags = {columns=columns}

    Settings.ui.update_current_column_stats(player, new_index)
end

local function apply_button_click(player)
    local window = player.gui.screen[Settings.ui.names.window]
    local columns = window.tags.columns

    Stats.ui.remove_columns(player)
    Settings.set(player.index, Settings.options.columns, columns)
    Stats.ui.update(player)
end

local function ok_button_click(player)
    local window = player.gui.screen[Settings.ui.names.window]

    apply_button_click(player)
    window.destroy()
end



EventDispatcher.register_event(defines.events.on_gui_opened, on_gui_opened)
EventDispatcher.register_event(defines.events.on_gui_closed, on_gui_closed)
EventDispatcher.register_event(defines.events.on_gui_click, on_gui_click)
EventDispatcher.register_event(defines.events.on_gui_checked_state_changed, on_gui_checked_state_changed)
EventDispatcher.register_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)



local self = {
    init = function(parent)
        on_gui_click_handlers = {
            [parent.ui.names.close_button] = close_click,
            [parent.ui.names.column_up_button] = column_up_click,
            [parent.ui.names.column_add_button] = column_add_click,
            [parent.ui.names.column_delete_button] = column_delete_click,
            [parent.ui.names.column_down_button] = column_down_click,
            [parent.ui.names.stat_up_button] = stat_up_click,
            [parent.ui.names.stat_add_button] = stat_add_click,
            [parent.ui.names.stat_delete_button] = stat_delete_click,
            [parent.ui.names.stat_down_button] = stat_down_click,
            [parent.ui.names.apply_button] = apply_button_click,
            [parent.ui.names.ok_button] = ok_button_click,
            [parent.ui.names.cancel_button] = close_click
        }

        self.init = nil
    end
}

return self