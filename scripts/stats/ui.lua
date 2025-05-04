local name_prefix = "GameStats20_ui__"
local names = {}
local strings = {
    "container",
    "content",
    "side_column",
    "stats_column",
    "settings_button"
}


for _, str in pairs(strings) do
    names[str] = name_prefix .. str
end


local function get_main_flow(player, create)
    if not player then
        return
    end

    create = create or true

    local show_background = player.mod_settings.gamestats20_show_background.value
    local float_stats = player.mod_settings.gamestats20_float_stats.value
    local gui

    if float_stats then
        gui = player.gui.screen
    else
        gui = player.gui.top
    end

    local container = gui[names.container]

    if not container then
        if not create then
            return
        end

        local container_style

        if show_background then
            container_style = "stats__container"
        else
            container_style = "stats__graphicless_container"
        end

        container = gui.add{
            type="frame", name=names.container, direction="horizontal", style=container_style
        }
    end

    local content

    if show_background then
        content = container[names.content] or container.add{
            type = "frame",
            name = names.content,
            direction = "horizontal",
            style = "stats__content"
        }
    else
        content = container
    end

    return {
        container = container,
        content = content
    }
end



local self = {
    default_columns = {},
    names = names
}

function self.align(player)
    if not player then
        return
    end

    if player.mod_settings.gamestats20_float_stats.value then
        return
    end

    local align = player.mod_settings.gamestats20_align.value

    if align == Settings.align_stats.no then
        return
    end

    local main_flow = get_main_flow(player)
    local parent = main_flow.container.parent
    local container_index = main_flow.container.get_index_in_parent()

    if align == Settings.align_stats.left then
        if container_index ~= 1 then
            parent.swap_children(container_index, 1)
        end
    elseif align == Settings.align_stats.right then
        local children_size = #parent.children

        if container_index ~= children_size then
            parent.swap_children(container_index, children_size)
        end
    end
end

function self.update(player)
    if not player then
        return
    end

    local main_flow = get_main_flow(player)
    local float_stats = player.mod_settings.gamestats20_float_stats.value

    local side_column = main_flow.content[names.side_column] or main_flow.content.add{
        type = "flow",
        name = names.side_column,
        direction = "vertical"
    }

    local settings_button = side_column[names.settings_button] or side_column.add{
        type = "sprite-button",
        name = names.settings_button,
        sprite = "gamestats20__list_white",
        hovered_sprite="gamestats20__list_black",
        clicked_sprite="gamestats20__list_black",
        style = "stats__settings_button",
        tooltip={"settings.settings"}
    }

    local column_settings = Settings.get(player.index, Settings.options.columns) or Stats.default_columns
    local values = Stats.get_stats(player)

    for index, column_item in pairs(column_settings) do
        local column_name = names.stats_column .. index
        local stats_column = main_flow.content[column_name]

        if not stats_column then
            stats_column = main_flow.content.add{
                type = "flow",
                name = column_name,
                direction = "vertical",
                style = "stats__column"
            }

            if float_stats then
                stats_column.drag_target = main_flow.container
            end
        end

        for _, stat_item in pairs(column_item) do
            local stat_name = name_prefix .. stat_item
            local caption = {"templates.stat", {"stats." .. stat_item}, values[stat_item]}
            local stat = stats_column[stat_name]

            if not stat then
                stats_column.add{
                    type = "label",
                    name = stat_name,
                    caption = caption,
                    ignored_by_interaction = true
                }
            else
                stat.caption = caption
            end
        end
    end
end

function self.remove_columns(player)
    if not player then
        return
    end

    local main_flow = get_main_flow(player)
    local column_settings = Settings.get(player.index, Settings.options.columns) or Stats.default_columns

    for index, _ in pairs(column_settings) do
        local column_name = names.stats_column .. index
        local column = main_flow.content[column_name]

        if column then
            column.destroy()
        end
    end
end

function self.remove(player)
    if not player then
        return
    end

    local container_name = name_prefix .. "container"

    if player.gui.top[container_name] then
        player.gui.top[container_name].destroy()
    elseif player.gui.screen[container_name] then
        player.gui.screen[container_name].destroy()
    end
end


return self
