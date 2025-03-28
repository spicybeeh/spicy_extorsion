local Framework = nil
local Shops = {}

-- Framework initialization
local function InitializeFramework()
    if Config.Framework == "ESX" then
        Framework = exports["es_extended"]:getSharedObject()
    elseif Config.Framework == "QBCore" then
        Framework = exports['qb-core']:GetCoreObject()
    end
end

-- Helper functions
local function GetPlayer(source)
    if Config.Framework == "ESX" then
        return Framework.GetPlayerFromId(source)
    else
        return Framework.Functions.GetPlayer(source)
    end
end

local function GetPlayerGang(source)
    local Player = GetPlayer(source)
    if not Player then return nil end

    if Config.Framework == "ESX" then
        return exports.rcore_gangs:getPlayerGang(source)
    else
        return Player.PlayerData.gang
    end
end

local function AddMoney(source, amount)
    local Player = GetPlayer(source)
    if not Player then return false end

    if Config.Framework == "ESX" then
        Player.addMoney(amount)
    else
        Player.Functions.AddMoney(Config.MoneyType, amount)
    end
    return true
end

-- Database functions
local function InitializeDatabase()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS spicy_extorsion (
            shop_id VARCHAR(50) PRIMARY KEY,
            gang_name VARCHAR(50),
            last_payment TIMESTAMP,
            cooldown TIMESTAMP
        )
    ]], {})

    MySQL.Async.fetchAll('SELECT * FROM spicy_extorsion', {}, function(results)
        if results then
            for _, shop in ipairs(results) do
                Shops[shop.shop_id] = {
                    gang = shop.gang_name,
                    lastPayment = shop.last_payment,
                    cooldown = shop.cooldown
                }
            end
        end
    end)
end

-- Main functionality
local function UpdateShopControl(shopId, gangName)
    Shops[shopId] = {
        gang = gangName,
        lastPayment = os.time(),
        cooldown = os.time() + (Config.ExtortionCooldown * 60)
    }

    MySQL.Async.execute([[
        INSERT INTO spicy_extorsion (shop_id, gang_name, last_payment, cooldown)
        VALUES (@shop_id, @gang_name, FROM_UNIXTIME(@last_payment), FROM_UNIXTIME(@cooldown))
        ON DUPLICATE KEY UPDATE
        gang_name = @gang_name,
        last_payment = FROM_UNIXTIME(@last_payment),
        cooldown = FROM_UNIXTIME(@cooldown)
    ]], {
        ['@shop_id'] = shopId,
        ['@gang_name'] = gangName,
        ['@last_payment'] = os.time(),
        ['@cooldown'] = os.time() + (Config.ExtortionCooldown * 60)
    })
end

-- Event handlers
RegisterNetEvent('spicy_extorsion:takeControl')
AddEventHandler('spicy_extorsion:takeControl', function(shopId)
    local source = source
    local gang = GetPlayerGang(source)
    
    if not gang then
        TriggerClientEvent('spicy_extorsion:notify', source, Config.Locale.not_in_gang)
        return
    end

    local gangName = type(gang) == "table" and gang.name or gang
    local controlledShops = 0
    
    for _, shop in pairs(Shops) do
        if shop.gang == gangName then
            controlledShops = controlledShops + 1
        end
    end

    if controlledShops >= Config.MaxShopsPerGang then
        TriggerClientEvent('spicy_extorsion:notify', source, Config.Locale.shop_limit)
        return
    end

    UpdateShopControl(shopId, gangName)
    TriggerClientEvent('spicy_extorsion:updateShops', -1, Shops)
    TriggerClientEvent('spicy_extorsion:notify', source, string.format(Config.Locale.shop_taken, Config.Shops[tonumber(shopId)].name))
end)

-- Payment system
CreateThread(function()
    while true do
        Wait(Config.PaymentInterval * 60 * 1000)
        local currentTime = os.time()
        local payments = {}

        for shopId, shop in pairs(Shops) do
            if shop.gang and currentTime - shop.lastPayment >= (Config.PaymentInterval * 60) then
                if not payments[shop.gang] then
                    payments[shop.gang] = 0
                end
                payments[shop.gang] = payments[shop.gang] + Config.PaymentAmount
                shop.lastPayment = currentTime

                MySQL.Async.execute('UPDATE spicy_extorsion SET last_payment = FROM_UNIXTIME(@time) WHERE shop_id = @shop_id', {
                    ['@time'] = currentTime,
                    ['@shop_id'] = shopId
                })
            end
        end

        for gangName, amount in pairs(payments) do
            local gangMembers = exports.rcore_gangs:getOnlineMembers(gangName)
            local splitAmount = math.floor(amount / #gangMembers)
            
            for _, playerId in ipairs(gangMembers) do
                if AddMoney(playerId, splitAmount) then
                    TriggerClientEvent('spicy_extorsion:notify', playerId, string.format(Config.Locale.payment_received, splitAmount))
                end
            end
        end
    end
end)

-- Initialization
CreateThread(function()
    InitializeFramework()
    InitializeDatabase()
    print('[spicy_extorsion] Server initialized successfully')