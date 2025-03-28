Config = {}

-- Framework settings
Config.Framework = "QBCore" -- "ESX" or "QBCore"
Config.Debug = false

-- Shop settings
Config.MinimumPolice = 0
Config.MoneyType = "cash" -- "cash" or "bank"
Config.PaymentInterval = 15 -- minutes
Config.PaymentAmount = 1500
Config.ExtortionCooldown = 30 -- minutes
Config.MaxShopsPerGang = 3

-- Notification settings
Config.NotifyType = "ox_lib" -- "ox_lib" or "custom"

-- Shop locations
Config.Shops = {
    {
        name = "24/7 Innocence Blvd",
        coords = vector3(25.7, -1347.3, 29.49),
        radius = 15.0,
        blip = {
            sprite = 52,
            color = 1,
            scale = 0.8
        }
    },
    {
        name = "LTD Gasoline Grove St",
        coords = vector3(-48.37, -1757.93, 29.42),
        radius = 15.0,
        blip = {
            sprite = 52,
            color = 1,
            scale = 0.8
        }
    },
    {
        name = "Rob's Liquor El Rancho",
        coords = vector3(1135.808, -982.281, 46.415),
        radius = 15.0,
        blip = {
            sprite = 52,
            color = 1,
            scale = 0.8
        }
    },
    {
        name = "24/7 Palomino Fwy",
        coords = vector3(2557.458, 382.282, 108.622),
        radius = 15.0,
        blip = {
            sprite = 52,
            color = 1,
            scale = 0.8
        }
    },
    {
        name = "LTD Gasoline Grapeseed",
        coords = vector3(1698.388, 4924.404, 42.063),
        radius = 15.0,
        blip = {
            sprite = 52,
            color = 1,
            scale = 0.8
        }
    }
}

-- Visual settings
Config.Markers = {
    type = 1,
    size = vector3(1.5, 1.5, 1.0),
    color = vector3(255, 0, 0),
    bobUpAndDown = true,
    faceCamera = true,
    rotate = true,
    drawDistance = 10.0
}

-- Language settings
Config.Locale = {
    shop_controlled = "This shop is controlled by %s",
    shop_available = "Press ~INPUT_CONTEXT~ to take control of this shop",
    shop_cooldown = "This shop is in cooldown for %s minutes",
    shop_taken = "You have taken control of %s",
    shop_limit = "Your gang has reached the maximum number of shops",
    payment_received = "You received $%s from your controlled shops",
    not_in_gang = "You need to be in a gang to do this",
    police_required = "Not enough police online"
}