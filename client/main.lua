---
ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
---
local Locales = {}

local function LoadLocale(locale)

    Locales = LoadResourceFile(GetCurrentResourceName(), "locales/" .. locale .. ".lua")

    if Locales then

        Locales = assert(load(Locales))()

    else
        print("Locale " .. locale .. "  failed to load!")
    end

end
---
LoadLocale(Config.Locale)
---
local function _U(str)
    return Locales[str] or str
end
---
local JobActive = false
local Blip = nil
local Truck = nil
local PlayerClothes = {}
---
Citizen.CreateThread(function()

    local hash = GetHashKey("s_m_m_trucker_01")
    
    RequestModel(hash)

    while not HasModelLoaded(hash) do
        Citizen.Wait(100)
    end

    local npc = CreatePed(4, hash, Config.NPCCoords.x, Config.NPCCoords.y, Config.NPCCoords.z, Config.NPCHeading, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)

    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_CLIPBOARD", 0, true)

end)
---
Citizen.CreateThread(function()

    while true do

        Citizen.Wait(0)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - Config.NPCCoords)

        if distance < 2.0 and not JobActive then

            ESX.ShowHelpNotification(_U("start_job"))

            if IsControlJustReleased(0, 38) then

                StartJob()

            end
        elseif JobActive and distance < 2.0 then

            ESX.ShowHelpNotification(_U("end_job"))

            if IsControlJustReleased(0, 38) then
                EndJob()
            end
        
        end

    end

end)
---
function StartJob()

    JobActive = true
    ESX.ShowNotification(_U("job_started"))

    TriggerEvent("skinchanger:getSkin", function(skin)
        PlayerClothes = skin
    end)

    local truckHash = GetHashKey(Config.Truck)
    RequestModel(truckHash)

    while not HasModelLoaded(truckHash) do
    
        Citizen.Wait(100)
    
    end

    Truck = CreateVehicle(truckHash, Config.NPCCoords.x + 5, Config.NPCCoords.y + 5, Config.NPCCoords.z, Config.NPCHeading, true, false)
    SetEntityAsMissionEntity(Truck, true, true)

    TriggerEvent("skinchanger:getSkin", function(skin)
        if skin.sex == 0 then
            TriggerEvent("skinchanger:loadClothes", skin, Config.Outfits.male)
        else
            TriggerEvent("skinchanger:loadClothes", skin, Config.Outfits.female)
        end
    end)

    SetNextDestination()

end
---
function EndJob()

    JobActive = false
    RemoveBlip(Blip)
    DeleteVehicle(Truck)
    Truck = nil
    ESX.ShowNotification("job_ended")

    if PlayerClothes ~= nil then
        TriggerEvent("skinchanger:loadSkin", PlayerClothes)
        PlayerClothes = {}
    end

end
---
function SetNextDestination()

    if not JobActive then return end

    local dest = Config.Destinations[math.random(1, #Config.Destinations)]
    Blip = AddBlipForCoord(dest.x, dest.y, dest.z)
    SetBlipRoute(Blip, true)
    ESX.ShowNotification(_U("next_destination"))

    Citizen.CreateThread(function()
    
        while JobActive do

            Citizen.Wait(0)

            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - vector3(dest.x, dest.y, dest.z))

            if distance < 10.0 then

                DrawMarker(1, dest.x, dest.y, dest.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.0, 0, 255, 0, 100, false, true, 2, false, false, false, false)

                if distance < 3.0 then

                    ESX.ShowHelpNotification(_U("deliver_goods"))

                    if IsControlJustReleased(0, 38) then

                        RemoveBlip()
                        local payment = math.random(Config.JobPaymentMin, Config.JobPaymentMax)
                        TriggerServerEvent("jx_trucker:pay", payment)
                        ESX.ShowNotification(_U("delivery_complete" .. payment))
                        SetNextDestination()

                    end

                end

            end

        end

    end)

end
---
Citizen.CreateThread(function()

    local jobBlip = AddBlipForCoord(Config.NPCCoords.x, Config.NPCCoords.y, Config.NPCCoords.z)

    SetBlipSprite(jobBlip, Config.BlipSprite)
    SetBlipDisplay(jobBlip, 4)
    SetBlipScale(jobBlip, Config.BlipScale)
    SetBlipColour(jobBlip, Config.BlipColour)
    SetBlipAsShortRange(jobBlip, false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipName)
    EndTextCommandSetBlipName(jobBlip)

end)
---