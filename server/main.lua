---
ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
---
RegisterNetEvent("jk_trucker:pay")
AddEventHandler("jk_trucker:pay", function(payment)

    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addMoney(payment)

end)
---