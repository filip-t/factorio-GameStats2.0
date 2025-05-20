local name_prefix = "GameStats20_settings_ui__"
local names = {}
local strings = {
    "window",
        "header",
            "close_button",
        "options",
            "show_all_checkbox",
        "content",
            "columns_flow",
                "columns_title",
                "columns",
            "column_buttons",
                "column_up_button",
                "column_add_button",
                "column_delete_button",
                "column_down_button",
            "current_column_flow",
                "current_column_title",
                "current_column",
            "stat_buttons",
                "stat_up_button",
                "stat_add_button",
                "stat_delete_button",
                "stat_down_button",
            "stats_flow",
                "stats_title",
                "stats",
        "button_bar",
            "apply_button",
            "ok_button",
            "cancel_button"
}

for _, str in pairs(strings) do
    names[str] = name_prefix .. str
end


local self = {
    names = names
}


function self.open(player)
    if not player then
        return
    end

    if player.gui.screen[self.names.window] then
        return
    end

    local window = player.gui.screen.add{type="frame", name=self.names.window, direction="vertical"}


    -- Header --
    local header = window.add{type="flow", name=self.names.header, direction="horizontal"}
    local title = header.add{type="label", caption={"settings.settings"}, style="frame_title"}
    local dragger = header.add{type="empty-widget", style="stats_settings__dragger"}
    dragger.drag_target = window

    local close_button = header.add{
        type="sprite-button",
        name=self.names.close_button,
        sprite="utility/close",
        hovered_sprite="utility/close_black",
        clicked_sprite="utility/close_black",
        style="close_button"
    }


    -- Options --

    local options = window.add{type="flow", name=self.names.options, direction="horizontal", style="stats_settings__content"}
    options.add{type="empty-widget", style="stats_settings__horizontal_spacer"}
    local show_all = options.add{
        type = "checkbox",
        name = self.names.show_all_checkbox,
        caption = {"settings.show_all"},
        state = false
    }


    -- Content --

    local content = window.add{type="flow", name=self.names.content, direction="horizontal", style="stats_settings__content"}

    local columns_flow = content.add{type="flow", name=self.names.columns_flow, direction="vertical"}
    local columns_title = columns_flow.add{
        type = "label",
        name = self.names.columns_title,
        caption = {"settings.columns"},
        style="stats_settings__column_title"
    }
    local columns = columns_flow.add{type="list-box", name=self.names.columns, style="stats_settings__column"}

    local column_buttons = content.add{type="flow", name=self.names.column_buttons, direction="vertical"}
    column_buttons.add{type="empty-widget", style="stats_settings__vertical_spacer"}
    local column_up_button = column_buttons.add{
        type="sprite-button",
        name=self.names.column_up_button,
        sprite="gamestats20__arrow_up_white",
        hovered_sprite="gamestats20__arrow_up_black",
        clicked_sprite="gamestats20__arrow_up_black",
        style = "stats_settings__action_button",
        tooltip = {"settings.column_up"}
    }
    local column_add_button = column_buttons.add{
        type="sprite-button",
        name=self.names.column_add_button,
        sprite="gamestats20__plus_white",
        hovered_sprite="gamestats20__plus_black",
        clicked_sprite="gamestats20__plus_black",
        style = "stats_settings__action_button",
        tooltip = {"settings.column_add"}
    }
    local column_del_button = column_buttons.add{
        type="sprite-button",
        name=self.names.column_delete_button,
        sprite="gamestats20__minus_white",
        hovered_sprite="gamestats20__minus_black",
        clicked_sprite="gamestats20__minus_black",
        style = "stats_settings__action_button",
        tooltip = {"settings.column_delete"}
    }
    local column_down_button = column_buttons.add{
        type="sprite-button",
        name=self.names.column_down_button,
        sprite="gamestats20__arrow_down_white",
        hovered_sprite="gamestats20__arrow_down_black",
        clicked_sprite="gamestats20__arrow_down_black",
        style = "stats_settings__action_button",
        tooltip = {"settings.column_down"}
    }
    column_buttons.add{type="empty-widget", style="stats_settings__vertical_spacer"}


    local current_column_flow = content.add{type="flow", name=self.names.current_column_flow, direction="vertical"}
    local current_column_title = current_column_flow.add{
        type = "label",
        name = self.names.current_column_title,
        style = "stats_settings__column_title"
    }
    local current_column = current_column_flow.add{
        type = "list-box",
        name = self.names.current_column,
        style = "stats_settings__column"
    }

    local stats_buttons = content.add{type="flow", name=self.names.stats_buttons, direction="vertical"}
    stats_buttons.add{type="empty-widget", style="stats_settings__vertical_spacer"}
    local stat_up_button = stats_buttons.add{
        type="sprite-button",
        name=self.names.stat_up_button,
        sprite="gamestats20__arrow_up_white",
        hovered_sprite="gamestats20__arrow_up_black",
        clicked_sprite="gamestats20__arrow_up_black",
        style = "stats_settings__action_button",
        tooltip = {"settings.stat_up"}
    }
    local stat_add_button = stats_buttons.add{
        type="sprite-button",
        name=self.names.stat_add_button,
        sprite="gamestats20__arrow_left_white",
        hovered_sprite="gamestats20__arrow_left_black",
        clicked_sprite="gamestats20__arrow_left_black",
        style = "stats_settings__action_button",
        tooltip = {"settings.stat_add"}
    }
    local stat_del_button = stats_buttons.add{
        type="sprite-button",
        name=self.names.stat_delete_button,
        sprite="gamestats20__arrow_right_white",
        hovered_sprite="gamestats20__arrow_right_black",
        clicked_sprite="gamestats20__arrow_right_black",
        style = "stats_settings__action_button",
        tooltip = {"settings.stat_delete"}
    }
    local stat_down_button = stats_buttons.add{
        type="sprite-button",
        name=self.names.stat_down_button,
        sprite="gamestats20__arrow_down_white",
        hovered_sprite="gamestats20__arrow_down_black",
        clicked_sprite="gamestats20__arrow_down_black",
        style = "stats_settings__action_button",
        tooltip = {"settings.stat_down"}
    }
    stats_buttons.add{type="empty-widget", style="stats_settings__vertical_spacer"}

    local stats_flow = content.add{type="flow", name=self.names.stats_flow, direction="vertical"}
    local stats_title = stats_flow.add{type="label", name=self.names.stats_title, style="stats_settings__column_title"}
    local stats = stats_flow.add{type="list-box", name=self.names.stats, style="stats_settings__column"}


    -- Buttons --

    local button_bar = window.add{
        type = "flow",
        name = self.names.button_bar,
        direction = "horizontal",
        style = "stats_settings__button_bar"
    }
    local button_bar_spacer = button_bar.add{type="empty-widget", style="stats_settings__horizontal_spacer"}
    local apply_button = button_bar.add{type="button", name=self.names.apply_button, caption={"settings.apply"}}
    local ok_button = button_bar.add{type="button", name=self.names.ok_button, caption={"settings.ok"}}
    local cancel_button = button_bar.add{type="button", name=self.names.cancel_button, caption={"settings.cancel"}}


    window.force_auto_center()
    player.opened = window
end

function self.update_columns(player, selected_index)
    if not player then
        return
    end

    local window = player.gui.screen[self.names.window]

    if not window then
        return
    end

    local content_flow = window[self.names.content]
    local columns_list = content_flow[self.names.columns_flow][self.names.columns]

    columns_list.clear_items()

    for _, index in pairs(columns_list.tags.indices) do
        columns_list.add_item({"templates.column", index})
    end

    if #columns_list.items > 0 then
        columns_list.selected_index = selected_index or 1
    end
end

function self.update_current_column_stats(player, selected_index)
    if not player then
        return
    end

    local window = player.gui.screen[self.names.window]

    if not window then
        return
    end

    local content_flow = window[self.names.content]
    local columns_list = content_flow[self.names.columns_flow][self.names.columns]
    local current_column_title = content_flow[self.names.current_column_flow][self.names.current_column_title]
    local current_column_stats_list = content_flow[self.names.current_column_flow][self.names.current_column]
    local current_column_index = columns_list.selected_index

    current_column_stats_list.clear_items()

    if #window.tags.columns == 0 or current_column_index == 0 then
        current_column_title.caption = {"settings.fields"}
        return
    end

    current_column_title.caption = {"templates.fields", columns_list.get_item(current_column_index)}

    local current_column_stats = window.tags.columns[current_column_index]

    for _, stat in pairs(current_column_stats) do
        current_column_stats_list.add_item({"stats."..stat})
    end

    if selected_index and #current_column_stats_list.items > 0 and selected_index <= #current_column_stats_list.items then
        current_column_stats_list.selected_index = selected_index
    else
        current_column_stats_list.selected_index = #current_column_stats_list.items or nil
    end
end

function self.update_available_stats(player, selected_index)
    if not player then
        return
    end

    local window = player.gui.screen[self.names.window]

    if not window then
        return
    end

    local show_all = window[self.names.options][self.names.show_all_checkbox]
    local content_flow = window[self.names.content]
    local stats_list = content_flow[self.names.stats_flow][self.names.stats]
    local stats_title = content_flow[self.names.stats_flow][self.names.stats_title]
    local stats

    if show_all.state then
        stats_title.caption = {"settings.all_fields"}
        stats = Stats.stat_names
    else
        stats_title.caption = {"settings.available_fields"}
        stats = stats_list.tags.available_stats
    end

    stats_list.clear_items()

    for _, stat in pairs(stats) do
       stats_list.add_item({"stats."..stat})
    end

    if selected_index and #stats_list.items > 0 and selected_index <= #stats_list.items then
        stats_list.selected_index = selected_index
    else
        stats_list.selected_index = #stats_list.items or nil
    end
end

function self.close(player)
    if not player then
        return
    end

    if player.gui.screen[self.names.window] then
        player.gui.screen[self.names.window].destroy()
    end
end


return self
