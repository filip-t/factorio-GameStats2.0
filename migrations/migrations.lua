if not storage.gamestats20 then
    storage.gamestats20 = {}
    if not storage.gamestats20 then
        for _, player in pairs(game.players) do
            storage.gamestats20[player.index] = {}
            storage.gamestats20[player.index].player.old_position = {x = 0, y = 0}
            storage.gamestats20[player.index].player.distance_foot = 0
            storage.gamestats20[player.index].player.distance_car = 0
            storage.gamestats20[player.index].player.distance_tank = 0
            storage.gamestats20[player.index].player.distance_train = 0
            storage.gamestats20[player.index].player.distance_spider = 0
        end
    end
end
