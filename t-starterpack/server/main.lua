local UtilsStarterPack = require('utils') 

-- Mendaftarkan callback untuk mendapatkan informasi pemain
UtilsStarterPack.registerServerCallback('t-general:starterpack:server:getPlayerInfo', function(source, cb)
    local player = UtilsStarterPack.framework == 'esx' and UtilsStarterPack.FrameworkObject.GetPlayerFromId(source) or UtilsStarterPack.FrameworkObject.Functions.GetPlayer(source)
    if not player then
        local defaultGender = UtilsStarterPack.framework == 'esx' and 'm' or 0
        cb(defaultGender, false, false)
        return
    end

    local gender = UtilsStarterPack.framework == 'esx' and player.get('sex') or player.PlayerData.charinfo.gender
    local PlayerId = UtilsStarterPack.getPlayerIdentifier(player)

    local tableName = UtilsStarterPack.framework == 'esx' and 'users' or 'players'
    local genderValue = UtilsStarterPack.framework == 'esx' and (gender == 'm' and 0 or 1) or gender

    MySQL.Async.fetchAll(string.format('SELECT starterpack_umum_received, starterpack_ladies_received FROM %s WHERE %s = ?', tableName, UtilsStarterPack.framework == 'esx' and 'identifier' or 'citizenid'), 
    { PlayerId }, function(result)
        if result[1] then
            cb(genderValue, result[1].starterpack_umum_received, result[1].starterpack_ladies_received)
        else
            cb(genderValue, false, false)
        end
    end)
end)

RegisterNetEvent('t-general:starterpack:server:giveStarterPack', function(packType, car)
    local src = source
    local player = UtilsStarterPack.framework == 'esx' and UtilsStarterPack.FrameworkObject.GetPlayerFromId(src) or UtilsStarterPack.FrameworkObject.Functions.GetPlayer(src)
    if not player then return end

    local PlayerId = UtilsStarterPack.getPlayerIdentifier(player)
    local tableName = UtilsStarterPack.framework == 'esx' and 'users' or 'players'
    local receivedColumn = packType == 'umum' and 'starterpack_umum_received' or 'starterpack_ladies_received'

    MySQL.Async.fetchScalar(string.format('SELECT %s FROM %s WHERE %s = ?', receivedColumn, tableName, UtilsStarterPack.framework == 'esx' and 'identifier' or 'citizenid'), { PlayerId }, function(received)
        if not received then
            MySQL.Async.execute(string.format('UPDATE %s SET %s = ? WHERE %s = ?', tableName, receivedColumn, UtilsStarterPack.framework == 'esx' and 'identifier' or 'citizenid'), 
            { true, PlayerId }, function()
                local items = Config.starterpacks[packType].item
                local vehicleModel = car

                for itemName, itemData in pairs(items) do
                    if itemName == 'cash' or itemName == 'money' then
                        UtilsStarterPack.addMoney(player, itemData.amount)
                    else
                        UtilsStarterPack.addItem(player, itemName, itemData.amount)
                    end
                end

                local plate = UtilsStarterPack.generatePlate()
                local vehicleTable = UtilsStarterPack.framework == 'esx' and 'owned_vehicles' or 'player_vehicles'
                local query = UtilsStarterPack.framework == 'esx' and 
                    'INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)' or 
                    'INSERT INTO player_vehicles (citizenid, license, vehicle, plate, state) VALUES (?, ?, ?, ?, ?)'

                local params = UtilsStarterPack.framework == 'esx' and { PlayerId, plate, json.encode({ model = vehicleModel }) } or 
                    { PlayerId, player.PlayerData.license, vehicleModel, plate, 0 }

                MySQL.Async.execute(query, params, function()
                    TriggerClientEvent('t-general:starterpack:client:spawnVehicle', src, vehicleModel, plate)
                    UtilsStarterPack.notifyPlayer(src, packType == 'umum' and 'Anda telah menerima Starter Pack Umum.' or 'Anda telah menerima Starter Pack Ladies.', 'success')
                end)
            end)
        else
            UtilsStarterPack.notifyPlayer(src, packType == 'umum' and 'Anda sudah pernah mengambil Starter Pack Umum.' or 'Anda sudah pernah mengambil Starter Pack Ladies.', 'error')
        end
    end)
end)

UtilsStarterPack.registerCommand('resetstarterpack', 'Reset a player\'s starter pack status (Admin Only)', {
    { name = 'id', help = 'Player ID' }
}, true, function(source, args)
    local targetId = tonumber(args[1])
    if not targetId then
        UtilsStarterPack.notifyPlayer(source, 'Invalid Player ID.', 'error')
        return
    end

    local targetPlayer = UtilsStarterPack.framework == 'esx' and UtilsStarterPack.FrameworkObject.GetPlayerFromId(targetId) or UtilsStarterPack.FrameworkObject.Functions.GetPlayer(targetId)
    if targetPlayer then
        local PlayerId = UtilsStarterPack.getPlayerIdentifier(targetPlayer)
        local tableName = UtilsStarterPack.framework == 'esx' and 'users' or 'players'
        local query = UtilsStarterPack.framework == 'esx' and 
            'UPDATE users SET starterpack_umum_received = ?, starterpack_ladies_received = ? WHERE identifier = ?' or 
            'UPDATE players SET starterpack_umum_received = ?, starterpack_ladies_received = ? WHERE citizenid = ?'

        local params = { false, false, PlayerId }

        MySQL.Async.execute(query, params, function(affectedRows)
            if affectedRows > 0 then
                print('reset starterpack for : ' .. PlayerId)
            end
        end)
    else
        UtilsStarterPack.notifyPlayer(source, 'Player not found.', 'error')
    end
end, 'admin')
