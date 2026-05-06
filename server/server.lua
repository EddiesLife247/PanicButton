-- Register the returnStreetName event globally
RegisterNetEvent('panicButton:returnStreetName', function(streetName, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    LogDebug("Received street name: " .. streetName .. " from player: " .. Player.PlayerData.name, 3)

    local job = Player.PlayerData.job.name
    local gang = Player.PlayerData.gang.name

    -- Check if nearest-postal is available
    local postalCode
    if GetResourceState("nearest-postal") == "started" then
        if exports["nearest-postal"] and exports["nearest-postal"].getPostal then
            postalCode = exports["nearest-postal"]:getPostal(coords)
        else
            postalCode = "N/A"
            LogDebug("nearest-postal export 'getPostal' is missing.", 2)
        end
    else
        postalCode = "N/A"
        LogDebug("nearest-postal resource is not loaded.", 2)
    end

    -- Determine the group to alert
    if gang and Config.PermittedGangs[gang] then
        LogDebug("Alerting gang members for gang: " .. gang, 1)
        TriggerClientEvent('panicButton:alert', -1, {
            group = "gang",
            name = gang,
            coords = coords,
            street = streetName,
            postal = postalCode,
            player = Config.DisplayPlayerName and Player.PlayerData.name or nil,
            job = Config.DisplayJobName and job or nil,
            gang = Config.DisplayGangName and gang or nil
        })
    elseif Config.PermittedJobs[job] then
        LogDebug("Alerting job members for job: " .. job, 1)
        TriggerClientEvent('panicButton:alert', -1, {
            group = "job",
            name = job,
            coords = coords,
            street = streetName,
            postal = postalCode,
            player = Config.DisplayPlayerName and Player.PlayerData.name or nil,
            job = Config.DisplayJobName and job or nil
        })
    elseif IsLeoJob(job) then
        LogDebug("Alerting all LEO job members for panic button activation", 1)
        TriggerClientEvent('panicButton:alert', -1, {
            group = "leo",
            name = "LEO",
            coords = coords,
            street = streetName,
            postal = postalCode,
            player = Config.DisplayPlayerName and Player.PlayerData.name or nil,
            job = Config.DisplayJobName and job or nil
        })
    end

    -- Always notify all LEO jobs if configured
    if Config.AlwaysNotifyLEO then
        LogDebug("Notifying all LEOs due to Config.AlwaysNotifyLEO setting", 1)
        TriggerClientEvent('panicButton:alert', -1, {
            group = "leo",
            name = "LEO",
            coords = coords,
            street = streetName,
            postal = postalCode,
            player = Config.DisplayPlayerName and Player.PlayerData.name or nil,
            job = Config.DisplayJobName and job or nil
        })
    end
end)



-- CreateUseableItem
QBCore.Functions.CreateUseableItem(Config.PanicButtonItem, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        LogDebug("Panic button activated by player: " .. Player.PlayerData.name, 3)

        TriggerClientEvent('ox_lib:notify', source, {
            type = 'info',
            description = 'Panic button activated. Alert sent!'
        })

        local coords = GetEntityCoords(GetPlayerPed(source))
        TriggerClientEvent('panicButton:getStreetName', source, coords)
    end
end)




function IsLeoJob(jobName)
    for _, leoJob in ipairs(Config.LeoJobs) do
        if jobName == leoJob then
            return true
        end
    end
    return false
end

RegisterNetEvent('panicButton:playSound', function(coords, group, name)
    local players = QBCore.Functions.GetPlayers()

    for _, playerId in ipairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            local playerGang = Player.PlayerData.gang.name
            local playerJob = Player.PlayerData.job.name

            if (group == "gang" and playerGang == name) or
               (group == "leo" and IsLeoJob(playerJob)) or
               (group == "job" and Config.PermittedJobs[playerJob]) then
                TriggerClientEvent('panicButton:playClientSound', playerId, coords)
            end
        end
    end
end)
-- Print a message to the server console when the script is loaded
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("^2[PANIC BUTTON]^0 Server-side script loaded, developed by EddiesLife247 Scripts. Support at: https://discord.eddieslife247.co.uk/")

        -- Check for updates asynchronously
        PerformHttpRequest("https://eddieslife247.co.uk/PanicButton/version.txt", function(statusCode, response, headers)
            if statusCode == 200 and response then
                local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
                local remoteVersion = response:match("%S+") -- Extract the version string

                if remoteVersion and currentVersion ~= remoteVersion then
                    print("^3[PANIC BUTTON]^0 A New Update is available on the keymaster site! Version: " .. remoteVersion)
                else
                    print("^2[PANIC BUTTON]^0 You are using the latest version.")
                end
            else
                print("^1[PANIC BUTTON]^0 Failed to check for updates. Status Code: " .. tostring(statusCode))
            end
        end, "GET", "", {['Content-Type'] = 'text/plain'})
    end
end)
