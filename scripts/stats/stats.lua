local util = require("__core__/lualib/util")


local function spell_index(num)
    local last_digit = num % 10

    if last_digit == 1 then
        return 1
    elseif last_digit > 1 and last_digit < 5 then
        return 2
    end

    return 3
end

local function separate_thousands(number, separator)
    if number < 1000 then
        return number
    end

    local triads = {}

    while true do
        table.insert(triads, 1, string.format("%03d", number % 1000))

        number = math.floor(number / 1000)

        if number < 1000 then
            table.insert(triads, 1, number % 1000)
            break
        end
    end

    return table.concat(triads, separator)
end

local function is_entity_type(what_type, entity_name)
    local prototype = game.entity_prototypes[entity_name]
    -- game.print(prototype.type)
    return prototype and prototype.type == what_type
end

local function is_biter(entity_name)
    return is_entity_type("unit", entity_name)
end

local function is_worm(entity_name)
    return is_entity_type("turret", entity_name)
end

local function is_spawner(entity_name)
    return is_entity_type("unit-spawner", entity_name)
end

local function calculate_game_time(player)
    local game_seconds = math.floor(game.ticks_played / 60)

    -- For testing hours > 0
    -- game_seconds = game_seconds + 16 * 3600

    -- For testing days > 0
    -- game_seconds = game_seconds + (128 * 24) * 3600

    local days = 0
    local hours = 0
    local minutes = 0
    local seconds = 0

    local time_format =  player.mod_settings.gamestats_time_format.value

    local seconds_in_minute = 60
    local second_in_hour = seconds_in_minute * 60
    local second_in_day = second_in_hour * 24

    if time_format ~= Settings.time_formats.hours then
        days = math.floor(game_seconds / second_in_day)
        game_seconds = game_seconds % second_in_day
    end

    hours = math.floor(game_seconds / second_in_hour)
    game_seconds = game_seconds % second_in_hour
    minutes = math.floor(game_seconds / seconds_in_minute)
    game_seconds = game_seconds % seconds_in_minute -- don't need, but for consistency
    seconds = game_seconds

    local game_time

    if time_format == Settings.time_formats.hours then
        game_time = string.format("%d:%02d:%02d", hours, minutes, seconds)
    elseif time_format == Settings.time_formats.slashes then
        game_time = string.format("%d/%02d/%02d", days, hours, minutes)
    else
        local index_d, index_h, index_m
        game_time = {""}

        if time_format == Settings.time_formats.words then
            index_d = spell_index(days)
            index_h = spell_index(hours)
            index_m = spell_index(minutes)
        else
            index_d = ""
            index_h = ""
            index_m = ""
        end

        if days > 0 then
            table.insert(game_time, {"templates."..time_format.."_d"..index_d, days})
            table.insert(game_time, " ")
        end

        if hours > 0 then
            table.insert(game_time, {"templates."..time_format.."_h"..index_h, hours})
            table.insert(game_time, " ")
        end

        table.insert(game_time, {"templates."..time_format.."_m"..index_m, minutes})
    end

    return game_time
end

local function calculate_evolution_percentage()
    local evolution_percentage = game.forces.enemy.evolution_factor * 100
    local whole_number = math.floor(evolution_percentage)
    local fractional_part = math.floor((evolution_percentage - whole_number) * 10000)

    return string.format("%d.%04d%%", whole_number, fractional_part)
end

local function calculate_online_players_count()
    return #game.connected_players
end

local function calculate_dead_players_count(player)
    return player.force.kill_count_statistics.output_counts["character"] or 0
end

local function calculate_killed_enemy_count(player)
    local killed_biters_count = 0
    local killed_worms_count = 0
    local destroyed_nests_count = 0
    local total_kill_count = 0

    -- For testing when numbers > 1k
    -- killed_biters_count = killed_biters_count + 342000
    -- killed_worms_count = killed_worms_count + 56000
    -- destroyed_nests_count = destroyed_nests_count + 3000

    -- For testing when numbers > 1M
    -- killed_biters_count = killed_biters_count + 256000000
    -- killed_worms_count = killed_worms_count + 17000000
    -- destroyed_nests_count = destroyed_nests_count + 5000000

    for entity_name, kill_count in pairs(player.force.kill_count_statistics.input_counts) do
        if is_biter(entity_name) then
            killed_biters_count = killed_biters_count + kill_count
        elseif is_worm(entity_name) then
            killed_worms_count = killed_worms_count + kill_count
        elseif is_spawner(entity_name) then
            destroyed_nests_count = destroyed_nests_count + kill_count
        end
    end

    total_kill_count = killed_biters_count + killed_worms_count + destroyed_nests_count

    local number_format =  player.mod_settings.gamestats_number_format.value

    if number_format == Settings.number_formats.round then
        killed_biters_count = util.format_number(killed_biters_count, true)
        killed_worms_count = util.format_number(killed_worms_count, true)
        destroyed_nests_count = util.format_number(destroyed_nests_count, true)
        total_kill_count = util.format_number(total_kill_count, true)
    elseif number_format ~= Settings.number_formats.full then
        local thousand_separator = Settings.thousand_separators[number_format]
        killed_biters_count = separate_thousands(killed_biters_count, thousand_separator)
        killed_worms_count = separate_thousands(killed_worms_count, thousand_separator)
        destroyed_nests_count = separate_thousands(destroyed_nests_count, thousand_separator)
        total_kill_count = separate_thousands(total_kill_count, thousand_separator)
    end

    return {
        [Stats.stats.killed_biters_count] = killed_biters_count,
        [Stats.stats.killed_worms_count] = killed_worms_count,
        [Stats.stats.destroyed_nests_count] = destroyed_nests_count,
        [Stats.stats.killed_enemy_count] = total_kill_count
    }
end

local function calculate_pollution(player)
    local surface = player.surface
    local position = player.position
    local pollution = surface.get_pollution(position)

    pollution = math.floor(pollution * 100) / 100

    return pollution
end

local function calculate_global_pollution(player)
    local surface = player.surface
    local pollution = surface.get_total_pollution()

    pollution = math.floor(pollution * 100) / 100

    return pollution
end

local self = {}

self.stat_names = {
    "game_time",
    "evolution_percentage",
    "online_players_count",
    "pollution",
    "global_pollution",
    "dead_players_count",
    "killed_biters_count",
    "killed_worms_count",
    "destroyed_nests_count",
    "killed_enemy_count"
}

self.stats = {}
for _, stat_name in pairs(self.stat_names) do
    self.stats[stat_name] = stat_name
end

self.default_columns = {
    {
        self.stats.game_time,
        self.stats.evolution_percentage,
        self.stats.dead_players_count
    },
    {
        self.stats.killed_biters_count,
        self.stats.killed_worms_count,
        self.stats.destroyed_nests_count
    }
}

function self.get_stats(player)
    local kill_counts = calculate_killed_enemy_count(player)

    return {
        [self.stats.game_time] = calculate_game_time(player),
        [self.stats.evolution_percentage] = calculate_evolution_percentage(),
        [self.stats.pollution] = calculate_pollution(player),
        [self.stats.global_pollution] = calculate_global_pollution(player),
        [self.stats.online_players_count] = calculate_online_players_count(),
        [self.stats.dead_players_count] = calculate_dead_players_count(player),
        [self.stats.killed_biters_count] = kill_counts[self.stats.killed_biters_count],
        [self.stats.killed_worms_count] = kill_counts[self.stats.killed_worms_count],
        [self.stats.destroyed_nests_count] = kill_counts[self.stats.destroyed_nests_count],
        [self.stats.killed_enemy_count] = kill_counts[self.stats.killed_enemy_count]
    }
end


self.ui = require("__GameStats__/scripts/stats/ui")
self.controller = require("__GameStats__/scripts/stats/controller")


return self