data:extend {
    {
        type = "bool-setting",
        name = "gamestats_show_game_time",
        setting_type = "runtime-per-user",
        default_value = true,
        order="01"
    },
    {
        type = "string-setting",
        name = "gamestats_time_format",
        setting_type = "runtime-per-user",
        default_value = "hours",
        allowed_values = {"hours", "words", "slashes"},
        order="02"
    },
    {
        type = "bool-setting",
        name = "gamestats_show_evolution_percentage",
        setting_type = "runtime-per-user",
        default_value = true,
        order="03"
    },
    {
        type = "bool-setting",
        name = "gamestats_show_online_players_count",
        setting_type = "runtime-per-user",
        default_value = true,
        order="04"
    },
    {
        type = "bool-setting",
        name = "gamestats_show_pollution",
        setting_type = "runtime-per-user",
        default_value = false,
        order="05"
    },
    {
        type = "bool-setting",
        name = "gamestats_show_dead_players_count",
        setting_type = "runtime-per-user",
        default_value = true,
        order="06"
    },
    {
        type = "string-setting",
        name = "gamestats_dead_players_count_column",
        setting_type = "runtime-per-user",
        default_value = "left",
        allowed_values = {"left", "right"},
        order="07"
    },
    {
        type = "bool-setting",
        name = "gamestats_show_killed_biters_count",
        setting_type = "runtime-per-user",
        default_value = true,
        order="08"
    },
    {
        type = "bool-setting",
        name = "gamestats_show_killed_worms_count",
        setting_type = "runtime-per-user",
        default_value = true,
        order="09"
    },
    {
        type = "bool-setting",
        name = "gamestats_show_destroyed_nests_count",
        setting_type = "runtime-per-user",
        default_value = true,
        order="10"
    },
    {
        type = "bool-setting",
        name = "gamestats_merge_kills",
        setting_type = "runtime-per-user",
        default_value = false,
        order="11"
    },
    {
        type = "string-setting",
        name = "gamestats_thousand_separator",
        setting_type = "runtime-per-user",
        default_value = "no",
        allowed_values = {"no", "space", "comma"},
        order="12"
    },
    {
        type = "bool-setting",
        name = "gamestats_show_background",
        setting_type = "runtime-per-user",
        default_value = true,
        order="13"
    },
    {
        type = "string-setting",
        name = "gamestats_align",
        setting_type = "runtime-per-user",
        default_value = "no",
        allowed_values = {"no", "left", "right"},
        order="14"
    }
}