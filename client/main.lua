local locale = SD.Locale.T
SD.Locale.LoadLocale('en')

local vehicleClasses = {
    ["Cycles"] = true,
    ["Boats"] = true,
    ["Helicopters"] = true,
    ["Trains"] = true,
}

local playerPedId = PlayerPedId()

local enabled = false
local maxSpeed = 0

local ToggleSpeedLimiter = function(veh, newSpeed)
    if enabled then
        enabled = false
        maxSpeed = 0
        SD.ShowNotification(locale('warning.speed_limiter_deactivated'), "warning")
        return
    end
    
    local ped = playerPedId
    if IsPedInAnyVehicle(ped, false) then
        if newSpeed then
            maxSpeed = newSpeed / 2.2369
        else
            maxSpeed = GetEntitySpeed(veh)
        end
        if maxSpeed > 0 and GetVehicleCurrentGear(veh) > 0 then
            local TransformedSpeed = math.floor(maxSpeed * 2.2369 + 0.5)
            SD.ShowNotification(locale('success.speed_limiter_activated') .. TransformedSpeed .. " Mph", "success")
            enabled = true
            CreateThread(function()
                while enabled do
                    Wait(0)
                    if not IsPedInAnyVehicle(ped, false) then
                        enabled = false
                        maxSpeed = 0
                        SD.ShowNotification(locale('warning.speed_limiter_deactivated'), "warning")
                        break
                    end
                    if GetEntitySpeed(veh) > maxSpeed then
                        DisableControlAction(0, 71, true)
                    else
                        EnableControlAction(0, 71, true)
                    end
                    if IsControlJustPressed(0, 73) then
                        enabled = false
                        maxSpeed = 0
                        SD.ShowNotification(locale('warning.speed_limiter_deactivated'), "warning")
                        break
                    end
                end
                EnableControlAction(0, 71, true)
            end)
        end
    end
end

RegisterCommand('speedlimiter', function(source, args)
    local ped = playerPedId
    local veh = GetVehiclePedIsIn(ped, false)
    local vehClass = GetVehicleClass(veh)
    local speedLimit = tonumber(args[1])

    if ped == GetPedInVehicleSeat(veh, -1) then
        if not vehicleClasses[vehClass] then
            ToggleSpeedLimiter(veh, speedLimit)
        else
            SD.ShowNotification(locale('error.speed_limiter_unavailable'), "error")
        end
    end
end, false)

RegisterCommand('speedLimiterUp', function()
    if not enabled then return end
    local testSpeed = maxSpeed + 1.5 / 2.2369
    local max = GetVehicleEstimatedMaxSpeed(GetVehiclePedIsIn(playerPedId, false))
    if testSpeed > max then
        SD.ShowNotification(locale('error.speed_limiter_max_reached'), "error")
        return
    end
    maxSpeed = testSpeed
    local TransformedSpeed = math.floor(maxSpeed * 2.2369 + 0.5)
    SD.ShowNotification(locale('success.speed_limiter_increased') .. TransformedSpeed .. " Mph", "success")
end, false)

RegisterCommand('speedLimiterDown', function()
    if not enabled then return end
    maxSpeed = maxSpeed - 1.5 / 2.2369
    if maxSpeed <= 1 then
        enabled = false
        maxSpeed = 0
        SD.ShowNotification(locale('warning.speed_limiter_deactivated'), "warning")
        return
    end
    local TransformedSpeed = math.floor(maxSpeed * 2.2369 + 0.5)
    SD.ShowNotification(locale('success.speed_limiter_decreased') .. TransformedSpeed .. " Mph", "success")
end, false)

RegisterKeyMapping('speedlimiter', locale('keymap.toggle_speed_limiter'), 'keyboard', 'M')
RegisterKeyMapping('speedLimiterUp', locale('keymap.raise_speed_limiter'), 'keyboard', 'COMMA')
RegisterKeyMapping('speedLimiterDown', locale('keymap.lower_speed_limiter'), 'keyboard', 'PERIOD')
