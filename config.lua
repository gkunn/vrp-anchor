Config = {}
Config.Debug = true -- Debug mode (true to print statement)

Config.locale = 'ja' -- Can be set to "ja" or "en

-- Model name of boat to be permitted
Config.AllowedBoats = {
    "dinghy",
}

-- Model name of helicopter to be permitted
Config.AllowedHelis = {
    "sparrow",
}

Config.MaxSpeed = 10.0  -- Speed limit to be unanchored
Config.MaxAltitude = 3.0  -- Maximum altitude at which the helicopter can maintain anchor

