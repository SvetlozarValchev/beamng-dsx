local socket = require("socket")
local Triggers = require("dsxTriggerEnum")
local CONFIG = require("../../config")

local M = {}

local udp = socket.udp()

local address = "127.0.0.1"
local port = 6969

local state = {
    throttle = 0,
    brake = 0,
    isABSActive = false,
    airSpeedKmh = 0,
    beamDamage = 0,
    wheelSlip = 0,
    engineLoad = 0,
    rpm = 0,
    maxRPM = 0,
    absActivationTime = 0
}
local lastBeamDamage = 0
local blinkStartTime = 0
local lastBlinkChange = 0
local isBlinking = false
local blinkState = false
local blinkCount = 0

-- Add update rate limiting
local lastUpdateTime = 0
local UPDATE_INTERVAL = 1 / 30 -- Limit to 30Hz

local function packetToJson(packet)
    return jsonEncode(packet)
end

local function send(data)
    local jsonData = packetToJson(data)
    udp:sendto(jsonData, address, port)
end

function lerp(a, b, t)
    return a + (b - a) * 0.5 * t
end

function inverseLerp(a, b, v)
    if a ~= b then
        return (v - a) / (b - a)
    end
    return 0
end

local function handleLeftTrigger()
    local absActive = state.isABSActive and (socket.gettime() - state.absActivationTime) > CONFIG.ABS_WAIT_TIME

    if absActive and CONFIG.ENABLE_ABS then
        return {
            type = Triggers.InstructionType.TriggerUpdate,
            parameters = {0, Triggers.Trigger.Left, Triggers.TriggerMode.CustomTriggerValue,
                          Triggers.CustomTriggerValueMode.VibrateResistance, CONFIG.ABS_VIBRATION_FREQUENCY, 1, 0, 0, 0,
                          0, 0}
        }
    else
        local isWheelSlip = state.wheelSlip > CONFIG.BRAKE_SLIP_THRESHOLD and 1 or 0

        if isWheelSlip == 1 and state.brake > 0.1 and CONFIG.ENABLE_BRAKE_SLIP then
            return {
                type = Triggers.InstructionType.TriggerUpdate,
                parameters = {0, Triggers.Trigger.Left, Triggers.TriggerMode.CustomTriggerValue,
                              Triggers.CustomTriggerValueMode.VibrateResistance, CONFIG.BRAKE_SLIP_VIBRATION_FREQUENCY,
                              1, 0, 0, 0, 0, 0}
            }
        else
            local startOfResistanceBrake = 1 * lerp(CONFIG.BRAKE_VALUE_MIN, CONFIG.BRAKE_VALUE_MAX, state.brake)
            local startOfResistance = lerp(CONFIG.BRAKE_RESISTANCE_MIN, CONFIG.BRAKE_RESISTANCE_MAX,
                startOfResistanceBrake)
            local airSpeed = math.min(100, inverseLerp(0, CONFIG.BRAKE_AIRSPEED_MAX, state.airSpeedKmh))
            local amountOfForceExcerted = math.min(255, lerp(CONFIG.BRAKE_FORCE_MIN, CONFIG.BRAKE_FORCE_MAX, airSpeed))

            return {
                type = Triggers.InstructionType.TriggerUpdate,
                parameters = {0, Triggers.Trigger.Left, Triggers.TriggerMode.CustomTriggerValue,
                              Triggers.CustomTriggerValueMode.Rigid, startOfResistance, amountOfForceExcerted, 255, 0,
                              0, 0, 0}
            }
        end
    end
end

local function handleRightTrigger()
    local isWheelSlip = state.wheelSlip > 10 and 1 or 0

    if isWheelSlip == 1 and state.throttle > 0.1 and CONFIG.ENABLE_THROTTLE_SLIP then
        return {
            type = Triggers.InstructionType.TriggerUpdate,
            parameters = {0, Triggers.Trigger.Right, Triggers.TriggerMode.CustomTriggerValue,
                          Triggers.CustomTriggerValueMode.VibratePulse, 255, 255, 3, 50, 0, 0, 0}
        }
    else
        local startOfResistanceThrottle = 1 * lerp(CONFIG.THROTTLE_VALUE_MIN, CONFIG.THROTTLE_VALUE_MIN, state.throttle)
        local startOfResistance = lerp(CONFIG.THROTTLE_RESISTANCE_MIN, CONFIG.THROTTLE_RESISTANCE_MAX,
            startOfResistanceThrottle)

        return {
            type = Triggers.InstructionType.TriggerUpdate,
            parameters = {0, Triggers.Trigger.Right, Triggers.TriggerMode.CustomTriggerValue,
                          Triggers.CustomTriggerValueMode.Rigid, startOfResistance, 0, 0, 0, 0, 0, 0}
        }
    end
end

local function handleRGB()
    if isBlinking and CONFIG.ENABLE_DAMAGE_LED then
        local currentTime = socket.gettime()
        local timeSinceStart = currentTime - blinkStartTime

        if currentTime - lastBlinkChange >= CONFIG.DAMAGE_BLINK_DURATION then
            lastBlinkChange = currentTime
            blinkState = not blinkState
            if blinkState == false then
                blinkCount = blinkCount + 1
            end
        end

        if blinkCount >= CONFIG.DAMAGE_BLINK_COUNT then
            isBlinking = false
            blinkCount = 0
            return {
                type = Triggers.InstructionType.RGBUpdate,
                parameters = {0, 0, 0, 0, 0, 0}
            }
        end

        return {
            type = Triggers.InstructionType.RGBUpdate,
            parameters = {0, blinkState and CONFIG.DAMAGE_LED_COLOR.r or 0,
                          blinkState and CONFIG.DAMAGE_LED_COLOR.g or 0, blinkState and CONFIG.DAMAGE_LED_COLOR.b or 0,
                          0, 0}
        }
    end

    return {
        type = Triggers.InstructionType.RGBUpdate,
        parameters = {0, 0, 0, 0, 0, 0}
    }
end

local function handleLED()
    local rpmPercentage = state.maxRPM > 0 and (state.rpm / state.maxRPM) or 0
    local rgbs = {false, false, false, false, false}

    if not CONFIG.ENABLE_RPM_LED then
        return {
            type = Triggers.InstructionType.PlayerLED,
            parameters = {0, 0, 0, 0, 0, 0}
        }
    end

    if rpmPercentage >= CONFIG.RPM_LED_ONE_THRESHOLD then
        rgbs[1] = true
    end
    if rpmPercentage >= CONFIG.RPM_LED_TWO_THRESHOLD then
        rgbs[2] = true
    end
    if rpmPercentage >= CONFIG.RPM_LED_THREE_THRESHOLD then
        rgbs[3] = true
    end
    if rpmPercentage >= CONFIG.RPM_LED_FOUR_THRESHOLD then
        rgbs[4] = true
    end
    if rpmPercentage >= CONFIG.RPM_LED_FIVE_THRESHOLD then
        rgbs[5] = true
    end

    return {
        type = Triggers.InstructionType.PlayerLED,
        parameters = {0, rgbs[1], rgbs[2], rgbs[3], rgbs[4], rgbs[5]}
    }
end

local function handleVehicleData()
    local currentTime = socket.gettime()
    if currentTime - lastUpdateTime < UPDATE_INTERVAL then
        return
    end
    lastUpdateTime = currentTime

    local instructions = {}

    if not isBlinking and state.beamDamage > lastBeamDamage and (state.beamDamage - lastBeamDamage) >=
        CONFIG.DAMAGE_THRESHOLD then
        isBlinking = true
        blinkStartTime = socket.gettime()
        lastBlinkChange = blinkStartTime
        blinkState = true
        blinkCount = 0
    end
    lastBeamDamage = state.beamDamage

    table.insert(instructions, handleLeftTrigger())
    table.insert(instructions, handleRightTrigger())
    table.insert(instructions, handleLED())
    table.insert(instructions, handleRGB())

    send({
        instructions = instructions
    })
end

local function dsxUpdate(throttle, brake, isABSActive, airSpeedKmh, beamDamage, wheelSlip, engineLoad, rpm, maxRPM)
    if isABSActive and not state.isABSActive then
        state.absActivationTime = socket.gettime()
    end

    state.throttle = throttle
    state.brake = brake
    state.isABSActive = isABSActive
    state.airSpeedKmh = airSpeedKmh
    state.beamDamage = beamDamage
    state.wheelSlip = wheelSlip
    state.engineLoad = engineLoad
    state.rpm = rpm
    state.maxRPM = maxRPM

    handleVehicleData()
end

M.dsxUpdate = dsxUpdate
return M
