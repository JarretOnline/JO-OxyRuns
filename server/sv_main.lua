local QBCore = exports['qb-core']:GetCoreObject()

--- Returns the amount of cops online and on duty
--- @return amount number - amount of cops
local GetCopCount = function()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, Player in pairs(players) do
        if Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    return amount
end

--- Calculates the amount of cash rolls to launder
--- @return retval number - amount
local GetLaunderAmount = function()
    local cops = GetCopCount()
    if cops > 10 then cops = 10 end -- cap at 10 cops for no insane returns
    local min = 300 + (cops * 100) -- 300 base + 100 per cop minimum
    local max = 600 + (cops * 190) -- 600 base + 190 per cop minimum
    local retval = math.random(min, max)
    return retval
end

RegisterNetEvent('qb-oxyruns:server:Reward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        -- Cash
        local cash = math.random(1000, 2000)
        Player.Functions.AddMoney("cash", cash, "oxy-money")

        -- Launder
        local moneys = math.random(2000, 3000)
        local item = Player.Functions.GetItemByName(Config.LaunderItem)
        local randomizer = math.random(1,100)
        if item ~= nil and randomizer <= 40 then
            local amount = item.amount
            local removeAmount = GetLaunderAmount()
            if removeAmount > amount then removeAmount = amount end
            Player.Functions.RemoveItem(Config.LaunderItem, removeAmount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.LaunderItem], "remove", removeAmount)
            Wait(250)
            Player.Functions.AddMoney('cash', moneys, 'oxy-launder')
            --TriggerClientEvent('QBCore:Notify', src, "EXCHANGED MARKED BILLS", "success", 2500)
            TriggerClientEvent('okokNotify:Alert', source, "WASHED", "TRADED MARKED BILLS", 3000, 'info')
        end

        -- Oxy
        local oxy = math.random(100)
        if oxy <= Config.OxyChance then
            Player.Functions.AddItem(Config.OxyItem, 1, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.OxyItem], "add", 1)
        end

        -- Rare loot
        local rareLoot = math.random(100)
        if rareLoot <= Config.RareLoot then
            Player.Functions.AddItem(Config.RareLootItem, 1, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareLootItem], "add", 1)
        end
    end
end)

QBCore.Functions.CreateCallback('qb-oxyruns:server:StartOxy', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.PlayerData.money.cash >= Config.StartOxyPayment then
        Player.Functions.RemoveMoney('cash', Config.StartOxyPayment, "oxy start")
        cb(true)
    else
       -- TriggerClientEvent('QBCore:Notify', src, "You don't have enough money to start an oxyrun..", "error",  3500)
        TriggerClientEvent('okokNotify:Alert', source, "ERROR", "NEED MONEYS", 2000, 'error')
        cb(false)
    end
end)
