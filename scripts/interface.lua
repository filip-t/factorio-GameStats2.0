local ModGui = require("__core__/lualib/mod-gui")

local Interface = {}
Interface.top_frame_name = "GameStats__top_frame"
Interface.inner_frame_name = "GameStats__inner_frame"
Interface.container_name = "GameStats__container"
Interface.left_column_name = "GameStats__left_column"
Interface.right_column_name = "GameStats__right_column"
Interface.game_time_name = "GameStats__game_time"
Interface.evolution_percentage_name = "GameStats__evolution_percentage"
Interface.online_players_count_name = "GameStats__online_players_count"
Interface.online_players_count_name = "GameStats__online_players_count"
Interface.killed_biters_count_name = "GameStats__killed_biters_count"
Interface.killed_worms_count_name = "GameStats__killed_worms_count"
Interface.destroyed_nests_count = "GameStats__destroyed_nests_count"
Interface.killed_enemy_count_name = "GameStats__killed_enemy_count"

local self = Interface


local function get_button_flow(player)
    if not player then
        return
    end

    local outer_frame = player.gui.top[self.top_frame_name] or player.gui.top.add{
        type="frame", name=self.top_frame_name, direction="horizontal", style="quick_bar_window_frame"
    }
    return outer_frame[self.inner_frame_name] or outer_frame.add{
        type="frame", name=self.inner_frame_name, direction="horizontal", style="mod_gui_inside_deep_frame"
    }
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
        local button_flow = ModGui.get_button_flow(player)
    end

    local container = button_flow[self.container_name] or button_flow.add{
        type="flow", name=self.container_name, direction="horizontal"
    }

    self.align_container(player)

    return container
end

function Interface.create()

end

function Interface.align_container(player)
    if not player then
        return
    end

    if not player.mod_settings.gamestats_always_on_left.value then
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

    parent.swap_children(container.get_index_in_parent(), 1)
end

function Interface.remove_container(player)
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