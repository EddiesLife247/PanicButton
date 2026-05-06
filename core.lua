QBCore = exports['qb-core']:GetCoreObject()

-- Debugging Function
function LogDebug(message, level)
    -- Default level to 2 ("Default") if not specified
    level = level or 2

    -- Define level names and colors
    local levelInfo = {
        [1] = {label = "Critical", color = "^1"}, -- Red
        [2] = {label = "Default", color = "^3"},  -- Yellow
        [3] = {label = "Verbose", color = "^2"}, -- Green
    }

    -- Get level details or fallback to default
    local info = levelInfo[level] or levelInfo[2]

    -- Check if the log should be displayed based on Config.Debug and Config.DebugLevel
    if Config.Debug and level <= Config.DebugLevel then
        print(string.format("%s[DEBUG][%s] %s^0", info.color, info.label, message))
    end
end


-- Function to Get Street Name from Coordinates (Client-Side Only)
function GetStreetNameFromCoord(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    local crossingName = GetStreetNameFromHashKey(crossingHash)

    if crossingName and crossingName ~= "" then
        return streetName .. " / " .. crossingName
    else
        return streetName
    end
end

-- Debug message on resource start
AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("^3[PANIC BUTTON]^0 Client-side script loaded, developed by EddiesLife247 Scripts.")
    end
    if CheckForKeymasterUpdates() == true then
        print("^3[PANIC BUTTON]^0 A New Update is available on the keymaster site, please speak to your developer to update this resource!")
    end
end)
CreateThread(function()
    LogDebug(
    "Panic Button has been loaded, developed by EddiesLife247 Scripts. Support at: https://discord.eddieslife247.co.uk/")
    print(
    "^2[PANC BUTTON]^0 Client-side script loaded, developed by EddiesLife247 Scripts. Support at: https://discord.eddieslife247.co.uk/")
end)




function CheckForKeymasterUpdates()
    if not Config.CheckUpdates then return end

    -- Use a custom file-based versioning system to check for updates
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
    PerformHttpRequest("https://eddieslife247.co.uk/PanicButton/version.txt", function(statusCode, response, headers)
        if statusCode == 200 and response then
            local remoteVersion = response:match("%S+") -- Extract the version string
            if remoteVersion and currentVersion ~= remoteVersion then
                LogDebug("A new update is available: " .. remoteVersion .. ". Please update your resource.", 1)
                Print("Update available")
                return true
            else
                LogDebug("You are using the latest version.", 1)
                Print("current version!")
                return false
            end
        else
            Print(statusCode)
            LogDebug("Failed to check for updates. Status Code: " .. tostring(statusCode), 1)
            return false
        end
    end, "GET", "", {['Content-Type'] = 'text/plain'})
    return false
end
