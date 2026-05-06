fx_version 'cerulean'
game 'gta5'
-- Resource Metadata
author 'EddiesLife247'
description 'A versatile Panic Button resource for QBCore framework. This script enables players to trigger a panic button that sends customizable alerts to team members, gangs, or law enforcement. It features configurable notifications, map blips, and sound effects.'
version '1.1.0'
lua54 'yes' -- This ensures the asset is compatible with Lua 5.4



shared_script 'config.lua'
shared_script 'core.lua'


client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}
escrow_ignore {
    'config.lua', -- Ignoring the main configuration file
    'README.md', -- Ignoring the readme file
    'sounds/*.ogg' -- Ignore all .ogg files in the sounds folder

}
files {
    'sounds/*.ogg'
}

dependency 'qb-core'
dependency 'ox_lib'