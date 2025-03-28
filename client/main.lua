local Framework = nil
local PlayerData = {}
local Shops = {}
local Blips = {}

-- Framework initialization
local function InitializeFramework()
    if Config.Framework == "ESX" then
        Framework = exports["es_extended"]:getSharedObject()
        
        RegisterNetEvent('esx:playerLoaded')
        AddEventHandler('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
        end)

        RegisterNetEvent('esx:setJob')
        AddEventHandler('esx:setJob', function(job)
            PlayerData.job = job
        end)
    elseif Config.Framework == "QBCore" then
        Framework = exports['qb-core']:GetCoreObject()
        
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = Framework.Functions.GetPlayerData()
        end)

        RegisterNetEvent('QBCore:Client:OnGangUpdate')
        AddEventHandler('QBCore:Client:OnGangUpdate', function(gang)
            PlayerData.gang = gang
        end)
    end
end

-- Utility functions
local function Notify(message)
    if Config.NotifyType == "ox_lib" then
        lib.notify({
            title = 'Shop Extortion',
            description = message,
            type = 'info'
        })
    else
        if Config.Framework == "ESX" then
            Framework.ShowNotification(message)
        else
            Framework.Functions.Notify(message)
        end
    end
end

local function CreateBlip(coords, sprite, color, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Markers.size.x)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function UpdateBlips()
    for _, blip in pairs(Blips) do
        RemoveBlip(blip)
    end
    Blips = {}

    for i, shop in ipairs(Config.Shops) do
        local color = 1
        if Shops[tostring(i)] and Shops[tostring(i)].gang then
            color = 49
        end
        Blips[i] = CreateBlip(shop.coords, shop.blip.sprite, color, shop.name)
    end
end

-- Event handlers
RegisterNetEvent('spicy_extorsion:notify')
AddEventHandler('spicy_extorsion:notify', function(message)
    Notify(message)
end)

RegisterNetEvent('spicy_extorsion:updateShops')
AddEventHandler('spicy_extorsion:updateShops', function(shops)
    Shops = shops
    UpdateBlips()
end)

-- Main thread
CreateThread(function()
    InitializeFramework()
    UpdateBlips()

    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i, shop in ipairs(Config.Shops) do
            local distance = #(playerCoords - shop.coords)
            
            if distance < Config.Markers.drawDistance then
                sleep = 0
                DrawMarker(
                    Config.Markers.type,
                    shop.coords.x, shop.coords.y, shop.coords.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    Config.Markers.size.x, Config.Markers.size.y, Config.Markers.size.z,
                    Config.Markers.color.x, Config.Markers.color.y, Config.Markers.color.z, 100,
                    Config.Markers.bobUpAndDown, Config.Markers.faceCamera, 2, Config.Markers.rotate, nil, nil, false
                )

                if distance < 2.0 then
                    local shopData = Shops[tostring(i)]
                    if shopData and shopData.gang then
                        lib.showTextUI(string.format(Config.Locale.shop_controlled, shopData.gang))
                    else
                        lib.showTextUI(Config.Locale.shop_available)
                        if IsControlJustReleased(0, 38) then -- E key
                            TriggerServerEvent('spicy_extorsion:takeControl', tostring(i))
                        end
                    end
                else
                    lib.hideTextUI()
                end
            end
        end

        Wait(sleep)
    end
end)

-- Debug
if Config.Debug then
    RegisterCommand('extorsion_reset', function()
        TriggerServerEvent('spicy_extorsion:debug_reset')
    end, false)
end