local self = {}

self.stat_names = {
    "game_time",
    "evolution_percentage",
    "online_players_count",
    "pollution",
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


local function calculate_game_time(player_index)
    local game_seconds = math.floor(game.ticks_played / 60)

    -- For testing hours > 0
    -- game_seconds = game_seconds + 16 * 3600

    -- For testing days > 0
    -- game_seconds = game_seconds + (128 * 24 + 16) * 3600

    local days = 0
    local hours = 0
    local minutes = 0
    local seconds = 0

    local time_format = Settings.get(player_index, Settings.time_format) or Settings.time_formats.hours

    if time_format ~= Settings.time_formats.hours then
        days = math.floor(game_seconds / (3600*24))
        game_seconds = game_seconds % (3600*24)
    end

    hours = math.floor(game_seconds / 3600)
    game_seconds = game_seconds % 3600
    minutes = math.floor(game_seconds / 60)
    seconds = game_seconds % 60

    local game_time

    if time_format ~= Settings.time_formats.hours then
        if time_format ~= Settings.time_formats.words then
            game_time = {""}

            if days > 0 then
                table.insert(game_time, {"interface.spell_days_"..Utils.spell_index(days), days})
                table.insert(game_time, " ")
            end

            if hours > 0 then
                table.insert(game_time, {"interface.spell_hours_"..Utils.spell_index(hours), hours})
                table.insert(game_time, " ")
            end

            table.insert(game_time, {"interface.spell_minutes_"..Utils.spell_index(minutes), minutes})
        elseif time_format ~= Settings.time_formats.slashes then
            game_time = string.format("%d/%02d/%02d", days, hours, minutes)
        else
            -- Fallback for unusual setting value. IDK how is this possible, but...
            game_time = "WRONG FORMAT"
        end
    else
        game_time = string.format("%d:%02d:%02d", hours, minutes, seconds)
    end

    return game_time
end

local function calculate_evolution_percentage()
    local evolution_percentage = game.forces.enemy.evolution_factor * 100
    local whole_number = math.floor(evolution_percentage)

    return string.format("%d.%04d", whole_number, math.floor((evolution_percentage - whole_number) * 10000))
end

local function calculate_online_players_count()
    return #game.connected_players
end

local function calculate_dead_players_count()
    return game.forces.player.kill_count_statistics.output_counts["character"] or 0
end

local function calculate_killed_enemy_count(player_index)
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

    for entity_name, kill_count in pairs(game.forces.player.kill_count_statistics.input_counts) do
        if Utils.is_biter(entity_name) then
            killed_biters_count = killed_biters_count + kill_count
        elseif Utils.is_worm(entity_name) then
            killed_worms_count = killed_worms_count + kill_count
        elseif Utils.is_spawner(entity_name) then
            destroyed_nests_count = destroyed_nests_count + kill_count
        end
    end

    total_kill_count = killed_biters_count + killed_worms_count + destroyed_nests_count

    local number_format = Settings.get(player_index, Settings.number_format) or Settings.number_formats.full
    local thousand_separator = Settings.get(player_index, Settings.thousand_separator) or Settings.thousand_separators.no

    if number_format == Settings.number_formats.full then
        if thousand_separator ~= Settings.thousand_separators.no then
            killed_biters_count = Utils.separate_thousands(killed_biters_count, thousand_separator)
            killed_worms_count = Utils.separate_thousands(killed_worms_count, thousand_separator)
            destroyed_nests_count = Utils.separate_thousands(destroyed_nests_count, thousand_separator)
            total_kill_count = Utils.separate_thousands(total_kill_count, thousand_separator)
        end
    else
        killed_biters_count = Utils.format_number(killed_biters_count, true)
        killed_worms_count = Utils.format_number(killed_worms_count, true)
        destroyed_nests_count = Utils.format_number(destroyed_nests_count, true)
        total_kill_count = Utils.format_number(total_kill_count, true)
    end

    return {
        [self.stats.killed_biters_count] = killed_biters_count,
        [self.stats.killed_worms_count] = killed_worms_count,
        [self.stats.destroyed_nests_count] = destroyed_nests_count,
        [self.stats.killed_enemy_count] = total_kill_count
    }
end

local function calculate_pollution(player)
    local pollution = 0

    if player and player.character then
        local surface = player.character.surface
        local position = player.character.position

        pollution = surface.get_pollution(position)
        pollution = math.floor(pollution * 100) / 100
    end

    return pollution
end


self.get_stats = function(player)
    local kill_counts = calculate_killed_enemy_count(player.index)

    return {
        [self.stats.game_time] = calculate_game_time(player.index),
        [self.stats.evolution_percentage] = calculate_evolution_percentage(),
        [self.stats.pollution] = calculate_pollution(player),
        [self.stats.online_players_count] = calculate_online_players_count(),
        [self.stats.dead_players_count] = calculate_dead_players_count(),
        [self.stats.killed_biters_count] = kill_counts[self.stats.killed_biters_count],
        [self.stats.killed_worms_count] = kill_counts[self.stats.killed_worms_count],
        [self.stats.destroyed_nests_count] = kill_counts[self.stats.killed_worms_count],
        [self.stats.killed_enemy_count] = kill_counts[self.stats.killed_enemy_count]
    }
end


return self