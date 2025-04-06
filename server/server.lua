local QBCore = exports['qb-core']:GetCoreObject()
local AnchoredVehicles = {}

RegisterNetEvent("vrp-anchor:server:toggleAnchor", function(plate)
    local src = source
    if not plate then return end

    local isAnchored = AnchoredVehicles[plate] or false
    AnchoredVehicles[plate] = not isAnchored

    TriggerClientEvent("vrp-anchor:client:updateAnchor", -1, plate, AnchoredVehicles[plate])
    
    TriggerClientEvent("vrp-anchor:client:notifyAnchor", src, AnchoredVehicles[plate])
end)

RegisterNetEvent("vrp-anchor:server:stateAnchor", function (plate)
    local src = source
    AnchoredVehicles[plate] = false
end)

QBCore.Functions.CreateCallback("vrp-anchor:server:getAnchorStatus", function(source, cb, plate)
    cb(AnchoredVehicles[plate] or false)
end)
