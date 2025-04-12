Config = {}
Config.Debug = false -- Debug mode (true to print statement)

Config.locale = 'ja' -- Can be set to "ja" or "en

-- Model name of boat to be permitted
Config.AllowedBoats = {
    "dinghy",
}

-- Model name of helicopter to be permitted
Config.AllowedHelis = {
    "sparrow",
}

Config.SpeedUnit = "mph"    -- "mph" or "kmh" (Please select the one you use in your environment)
Config.MaxSpeed = 10.0      -- Speed limit to be unanchored
Config.MaxAltitude = 3.0    -- Maximum altitude at which the helicopter can maintain anchor

