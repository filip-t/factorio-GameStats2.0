local style = data.raw["gui-style"]["default"]


-- Stats styles --

style.stats__container = {
    type = "frame_style",
    padding = 0
}

--style.stats__graphicless_container = {
--    type = "frame_style",
--    parent = "graphicless_frame",
--    padding = 0
--}

style.stats__content = {
    type = "frame_style",
    parent = "inside_deep_frame",
    padding = 0
}

style.stats__column = {
    type = "vertical_flow_style",
    padding = 5,
    left_padding = 0,
    right_padding = 8
}

style.stats__settings_button = {
    type = "button_style",
    parent = "slot_button",
    size = 20,
    top_margin = 8,
    left_margin = 8,
    right_margin = 5
}


-- Stats settings styles --

style.stats_settings__dragger = {
    type = "empty_widget_style",
    parent = "draggable_space",
    horizontally_stretchable = "on",
    height = 24
}

style.stats_settings__action_button = {
    type = "button_style",
    parent = "frame_action_button",
    size = 24
}

style.stats_settings__horizontal_spacer = {
    type = "empty_widget_style",
    horizontally_stretchable = "on"
}

style.stats_settings__vertical_spacer = {
    type = "empty_widget_style",
    vertically_stretchable = "on"
}

style.stats_settings__content = {
    type = "horizontal_flow_style",
    top_margin = 8,
    left_margin = 5,
    right_margin = 5
}
style.stats_settings__column_title = {
    type = "label_style",
    left_margin = 5
}

style.stats_settings__column = {
    type = "list_box_style",
    width = 150,
    height = 300
}

style.stats_settings__button_bar = {
    type = "horizontal_flow_style",
    top_margin = 25,
    bottom_margin = 10,
    left_margin = 5,
    right_margin = 5
}
