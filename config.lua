-- config.lua
Config = {}

Config.PanicButtonItem = "panic_button" -- Name of the item for the panic button
Config.LeoJobs = {"police", "highways", "ambulance", "fire", "staff", "government"} -- Predefined LEO jobs, these jobs get alerts when always notify leo is enabled, or if one player in any of the jobs alerts.
Config.PermittedGangs = {"ballas", "vagos", "families"} -- List of gangs permitted to use the panic button
Config.PermittedJobs = {"mechanic", "police", "ambulance", "highways", "fire", "staff", "government"} -- List of jobs allowed to use the panic button
Config.AlertDuration = 60000 -- Duration for map blip (in milliseconds)
Config.AlwaysNotifyLEO = false -- Whether LEOs are always notified of panic button activations
Config.DisplayPlayerName = true -- Whether to display the player's name in the alert
Config.DisplayJobName = true -- Whether to display the player's job in the alert
Config.DisplayGangName = true -- Whether to display the player's gang name in the alert
Config.UsePostalCode = false -- requires nearest postal, will display the postal in the dispatch/alert
Config.UsePSDispatch = true -- will send the alert to ps dispatch as well for leo jobs.
Config.DebugLevel = 3
Config.Debug = true

Config.AlertDescription = "A Panic Button has been activated!"
Config.SoundSystem = "xsound" -- Options: "xsound", "interactsound", "default"
Config.XSoundFile = "alerts" -- Name of the sound file for xsound
Config.XSoundVolume = 0.5 -- Volume for xsound playback
Config.XSoundDistance = 50 -- Distance for xsound playback


Config.InteractSoundFile = "alerts" -- Name of the sound file for InteractSound
Config.SoundVolume = 0.5 -- Volume for InteractSound

Config.DefaultSound = { -- Default native sound settings
    name = "Police_Siren", -- Sound name
    set = "DLC_HEIST_HACKING_SNAKE_SOUNDS" -- Sound set
}
