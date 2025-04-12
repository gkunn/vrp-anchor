local QBCore = exports['qb-core']:GetCoreObject()
local isAnchored
local lastVehicle = nil
local isLastVehicleHeli = false

local function IsAllowedBoat(vehicle)
    local model = GetEntityModel(vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(model):lower()

    if Config.Debug then
        print("vehicle model : " .. vehicleName)
    end

    for _, boat in ipairs(Config.AllowedBoats) do
        if vehicleName == boat then
            return true
        end
    end
    return false
end

local function IsAllowedHeli(vehicle)
    local model = GetEntityModel(vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(model):lower()

    if Config.Debug then
        print("vehicle model : " .. vehicleName)
    end

    for _, heli in ipairs(Config.AllowedHelis) do
        if vehicleName == heli then
            return true
        end
    end
    return false
end

local function GetAltitude(vehicle)
    local vehCoords = GetEntityCoords(vehicle)
    local _, groundZ = GetGroundZFor_3dCoord(vehCoords.x, vehCoords.y, vehCoords.z, true)
    return vehCoords.z - groundZ
end

local function ToggleAnchor()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local plate = GetVehicleNumberPlateText(vehicle)

    if not vehicle or GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
        QBCore.Functions.Notify(Locales[Config.locale].not_driver, "error")
        return
    end

    local model = GetEntityModel(vehicle)

    if IsThisModelABoat(model) then
        IsBoat = IsAllowedBoat(vehicle)
    elseif IsThisModelAHeli(model) then
        IsHeli = IsAllowedHeli(vehicle)
    end

    if not IsBoat and not IsHeli then
        QBCore.Functions.Notify(Locales[Config.locale].not_allowed_vehicle, "error")
        return
    end

    local speed = GetEntitySpeed(vehicle)
    if speed > Config.MaxSpeed then
        QBCore.Functions.Notify(string.format(Locales[Config.locale].speed_too_high, Config.MaxSpeed, Config.SpeedUnit),"error")
        return
    end

    if IsHeli then
        local altitude = GetAltitude(vehicle)
        if altitude > Config.MaxAltitude then
            QBCore.Functions.Notify(string.format(Locales[Config.locale].altitude_too_high, Config.MaxAltitude), "error")
            return
        end
    end

    TriggerServerEvent("vrp-anchor:server:toggleAnchor", plate)
    lastVehicle = vehicle
    isLastVehicleHeli = IsHeli
end

local function GetClosestVehicleToPlate(plate)
    local vehicles = GetGamePool("CVehicle")
    for _, vehicle in ipairs(vehicles) do
        if GetVehicleNumberPlateText(vehicle) == plate then
            return vehicle
        end
    end
    return nil
end

RegisterNetEvent("vrp-anchor:client:updateAnchor", function(plate, state)
    local vehicle = GetClosestVehicleToPlate(plate)
    if vehicle then
        SetBoatAnchor(vehicle, state)
    end
end)

RegisterNetEvent("vrp-anchor:client:notifyAnchor", function(state)
    isAnchored = state
    if isAnchored then
        isAnchored = true
        QBCore.Functions.Notify(Locales[Config.locale].anchor_success, "success")
    else
        isAnchored = false
        QBCore.Functions.Notify(Locales[Config.locale].anchor_cancel, "success")
    end
end)

CreateThread(function()
    while true do
        local sleep = 2000

        if isAnchored and lastVehicle then
            sleep = 1000

            local speed = GetEntitySpeed(lastVehicle)
            if Config.SpeedUnit == "kmh" then
                displaySpeed = speed * 3.6
            elseif Config.SpeedUnit == "mph" then
                displaySpeed = speed * 2.236936
            end

            if displaySpeed > Config.MaxSpeed then
                isAnchored = false
                SetBoatAnchor(lastVehicle, false)
                QBCore.Functions.Notify(Locales[Config.locale].anchor_removed_speed, "error")
                TriggerServerEvent("vrp-anchor:server:stateAnchor", GetVehicleNumberPlateText(lastVehicle))
            end

            if isLastVehicleHeli then
                local altitude = GetAltitude(lastVehicle)
                if altitude > Config.MaxAltitude then
                    isAnchored = false
                    SetBoatAnchor(lastVehicle, false)
                    QBCore.Functions.Notify(Locales[Config.locale].anchor_removed_altitude, "error")
                    TriggerServerEvent("vrp-anchor:server:stateAnchor", GetVehicleNumberPlateText(lastVehicle))
                end
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if isAnchored and lastVehicle then
            local speed = GetEntitySpeed(lastVehicle)
            if speed < 3.0 then
                SetEntityVelocity(lastVehicle, vector3(0.0, 0.0, 0.0))
            end
        end
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if vehicle then
            local plate = GetVehicleNumberPlateText(vehicle)
            QBCore.Functions.TriggerCallback("vrp-anchor:server:getAnchorStatus", function(state)
                if state then
                    SetBoatAnchor(vehicle, true)
                end
            end, plate)
        end
        
        Wait(5000)
    end
end)

RegisterCommand("anchor", function()
    ToggleAnchor()
end, false)

TriggerEvent('chat:addSuggestion', '/anchor', '錨(アンカー)を下ろす/上げる', {

})

-- Event for radial menu registration
RegisterNetEvent("vrp-anchor:client:anchor", function()
    ToggleAnchor()
end)
