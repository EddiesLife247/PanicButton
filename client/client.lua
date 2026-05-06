local activeBlips = {} -- Table to track active blips

RegisterNetEvent('panicButton:alert', function(data)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local PSDispatchSent = false
    LogDebug("Got panic button request to play alert - adding data!", 2)

    if (data.group == "gang" and PlayerData.gang.name == data.name) or
        (data.group == "leo" and IsLeoJob(PlayerData.job.name)) or
        (data.group == "job" and Config.PermittedJobs[PlayerData.job.name]) then
        local alertDescription = Config.AlertDescription

        if data.street then
            alertDescription = alertDescription .. ' Location: ' .. data.street
        end

        if data.postal and Config.UsePostalCode then
            alertDescription = alertDescription .. ' [Postal: ' .. data.postal .. ']'
        end

        if Config.DisplayPlayerName and data.player then
            alertDescription = alertDescription .. '\nPlayer: ' .. data.player
        end

        if Config.DisplayJobName and data.job then
            alertDescription = alertDescription .. '\nJob: ' .. data.job
        end

        if Config.DisplayGangName and data.gang then
            alertDescription = alertDescription .. '\nGang: ' .. data.gang
        end

        LogDebug("Displaying alert notification to client.", 3)
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            description = alertDescription,
            position = 'top-center',
            duration = 15000,
            style = {
                color = 'white',
                fontSize = '24px',
                fontWeight = 'bold',
                borderRadius = '10px',
                padding = '15px',
                boxShadow = '0 0 10px rgba(0, 0, 0, 0.5)',
            }
        })

        if data.group == "leo" and Config.UsePSDispatch and GetResourceState("ps-dispatch") == "started" then
            LogDebug("Sending PS Dispatch alert for LEO.", 1)
        exports['screenshot-basic']:requestScreenshotUpload('https://discord.com/api/webhooks/1337913956223684641/ZwTmvNkcp3PhDxugaN4pGSw1Wipn5sHD_Qv0dIeMdZP0jS8s7jIwTlptbwfmwYSkteBW', "files[]", function(val)
            local image = json.decode(val)

    exports.dusa_dispatch:CustomDispatch({
        title = 'Panic Button Triggered',
        description = 'A Panic Button has been activated!',
        code = '10-90',
        priority = 2,
        coords = coords,
        img = image.attachments[1].proxy_url,
        recipientJobs = {'police', 'response', 'firearms', 'roadspolicing', 'cid'}
    })
end)
            PSDispatchSent = true
        end
        if PSDispatchSent == false then
            LogDebug("Alert Sent, adding blip to map!", 3)
            local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
            SetBlipSprite(blip, 161)
            SetBlipScale(blip, 1.5)
            SetBlipColour(blip, 1)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('Panic Button Alert')
            EndTextCommandSetBlipName(blip)

            -- Store the blip in the activeBlips table
            activeBlips[blip] = blip
        end

        -- Trigger sound only for valid clients
        TriggerEvent('panicButton:playClientSound', data.coords, data.group, data.name)

        Citizen.CreateThread(function()
            if PSDispatchSent == true then
                LogDebug("Waiting to remove blip...", 3)
                Citizen.Wait(Config.AlertDuration)
                if activeBlips[blip] and DoesBlipExist(blip) then
                    LogDebug("Alert Finished, Removing Blip", 1)
                    RemoveBlip(activeBlips[blip])
                    activeBlips[blip] = nil
                    LogDebug("Blips Removed", 1)
                else
                    LogDebug("Blip already removed or does not exist.", 1)
                end
            end
        end)
    end
end)

-- Remove all active blips when the resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        LogDebug("Resource stopping, removing all active blips.", 2)
        for _, blip in pairs(activeBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        activeBlips = {} -- Clear the blips table
    end
end)






RegisterNetEvent('panicButton:getStreetName', function(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    local crossingName = GetStreetNameFromHashKey(crossingHash)

    if crossingName and crossingName ~= "" then
        streetName = streetName .. " / " .. crossingName
    end
    LogDebug("Got street name: " .. streetName .. " at coords: " .. coords, 3)

    -- Send the street name and coordinates back to the server
    TriggerServerEvent('panicButton:returnStreetName', streetName, coords)
end)




RegisterNetEvent('panicButton:playClientSound', function(coords, group, name)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - coords)
    local PlayerData = QBCore.Functions.GetPlayerData()

    -- Ensure the player belongs to the correct group
    if distance < 50.0 then
        if (group == "leo" and IsLeoJob(PlayerData.job.name)) or
            (group == "gang" and PlayerData.gang.name == name) or
            (group == "job" and Config.PermittedJobs[PlayerData.job.name]) then
            LogDebug("Playing panic button sound for nearby client.", 2)

            if Config.SoundSystem == "xsound" then
                -- Use xsound
                local resourceFilePath = "nui://" ..
                    GetCurrentResourceName() .. "/sounds/" .. Config.XSoundFile .. ".ogg"
                if GetResourceState("xsound") == "started" then
                    exports["xsound"]:PlayUrl("panic_button", resourceFilePath, Config.XSoundVolume)
                    exports["xsound"]:Distance("panic_button", Config.XSoundDistance) -- Set playback distance
                    LogDebug("Playing xsound from resource file: " .. resourceFilePath, 3)
                else
                    LogDebug("xsound resource not found. Falling back to default sound.", 1)
                    PlaySoundFrontend(-1, Config.DefaultSound.name, Config.DefaultSound.set, true)
                end
            elseif Config.SoundSystem == "interactsound" then
                -- Use InteractSound
                if GetResourceState("InteractSound") == "started" then
                    TriggerServerEvent('InteractSound_SV:PlayOnSource', Config.InteractSoundFile, Config.SoundVolume)
                    LogDebug("Triggering InteractSound with file: " .. Config.InteractSoundFile, 3)
                else
                    LogDebug("InteractSound resource not found. Falling back to default sound.", 1)
                    PlaySoundFrontend(-1, Config.DefaultSound.name, Config.DefaultSound.set, true)
                end
            else
                -- Use default native sound
                if Config.DefaultSound.name and Config.DefaultSound.set then
                    PlaySoundFrontend(-1, Config.DefaultSound.name, Config.DefaultSound.set, true)
                    LogDebug("Playing native sound: " .. Config.DefaultSound.name, 3)
                else
                    LogDebug("Default sound settings are missing in Config.", 1)
                end
            end
        end
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
