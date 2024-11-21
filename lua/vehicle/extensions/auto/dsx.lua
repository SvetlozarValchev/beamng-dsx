local socket = require("socket")
local CONFIG = require("../../../config")

local Triggers = {
    TriggerMode = {
        Normal = 0,
        GameCube = 1,
        VerySoft = 2,
        Soft = 3,
        Hard = 4,
        VeryHard = 5,
        Hardest = 6,
        Rigid = 7,
        VibrateTrigger = 8,
        Choppy = 9,
        Medium = 10,
        VibrateTriggerPulse = 11,
        CustomTriggerValue = 12,
        Resistance = 13,
        Bow = 14,
        Galloping = 15,
        SemiAutomaticGun = 16,
        AutomaticGun = 17,
        Machine = 18
    },
    CustomTriggerValueMode = {
        OFF = 0,
        Rigid = 1,
        RigidA = 2,
        RigidB = 3,
        RigidAB = 4,
        Pulse = 5,
        PulseA = 6,
        PulseB = 7,
        PulseAB = 8,
        VibrateResistance = 9,
        VibrateResistanceA = 10,
        VibrateResistanceB = 11,
        VibrateResistanceAB = 12,
        VibratePulse = 13,
        VibratePulseA = 14,
        VibratePulsB = 15,
        VibratePulseAB = 16
    },
    Trigger = {
        Invalid = 0,
        Left = 1,
        Right = 2
    },
    InstructionType = {
        Invalid = 0,
        TriggerUpdate = 1,
        RGBUpdate = 2,
        PlayerLED = 3,
        TriggerThreshold = 4,
        MicLED = 5,
        PlayerLEDNewRevision = 6
    },
    PlayerLEDNewRevision = {
        One = 0,
        Two = 1,
        Three = 2,
        Four = 3,
        Five = 4,
        AllOff = 5
    }
}

local UPDATE_INTERVAL = 1 / 60 -- Limit to 60Hz

local udp = socket.udp()
local address = "127.0.0.1"
local port = 6969

local state = {
    throttle = 0,
    brake = 0,
    isABSActive = false,
    airSpeedKmh = 0,
    beamDamage = 0,
    lastBeamDamage = 0,
    wheelSlip = 0,
    engineLoad = 0,
    rpm = 0,
    maxRPM = 0,
    absActivationTime = 0,
    blinkStartTime = 0,
    lastBlinkChange = 0,
    isBlinking = false,
    blinkState = false,
    blinkCount = 0,
    lastUpdateTime = 0
}

local function packetToJson(packet)
    return jsonEncode(packet)
end

local function send(data)
    local jsonData = packetToJson(data)
    udp:sendto(jsonData, address, port)
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function inverseLerp(a, b, v)
    if a ~= b then
        return (v - a) / (b - a)
    end
    return 0
end

local function calculateCombinedForce(brake, speed)
    local brakeNormalized = math.max(0, math.min(1, (brake - CONFIG.BRAKE_VALUE_MIN) /
        (CONFIG.BRAKE_VALUE_MAX - CONFIG.BRAKE_VALUE_MIN)))
    local speedNormalized = math.min(1.0, speed / CONFIG.BRAKE_AIRSPEED_MAX)

    local combinedFactor = brakeNormalized * speedNormalized

    return math.min(255, lerp(CONFIG.BRAKE_FORCE_MIN, CONFIG.BRAKE_FORCE_MAX, combinedFactor))
end

local function handleLeftTrigger()
    local absActive = state.isABSActive and (socket.gettime() - state.absActivationTime) > CONFIG.ABS_WAIT_TIME

    if absActive and CONFIG.ENABLE_ABS then
        return {
            type = Triggers.InstructionType.TriggerUpdate,
            parameters = {CONFIG.CONTROLLER_INDEX, Triggers.Trigger.Left, Triggers.TriggerMode.CustomTriggerValue,
                          Triggers.CustomTriggerValueMode.VibrateResistance, CONFIG.ABS_VIBRATION_FREQUENCY, 1, 0, 0, 0,
                          0, 0}
        }
    else
        local isWheelSlip = state.wheelSlip > CONFIG.BRAKE_SLIP_THRESHOLD and 1 or 0

        if isWheelSlip == 1 and state.brake > 0.1 and CONFIG.ENABLE_BRAKE_SLIP then
            return {
                type = Triggers.InstructionType.TriggerUpdate,
                parameters = {CONFIG.CONTROLLER_INDEX, Triggers.Trigger.Left, Triggers.TriggerMode.CustomTriggerValue,
                              Triggers.CustomTriggerValueMode.VibrateResistance, CONFIG.BRAKE_SLIP_VIBRATION_FREQUENCY,
                              1, 0, 0, 0, 0, 0}
            }
        else
            return {
                type = Triggers.InstructionType.TriggerUpdate,
                parameters = {CONFIG.CONTROLLER_INDEX, Triggers.Trigger.Left, Triggers.TriggerMode.CustomTriggerValue,
                              Triggers.CustomTriggerValueMode.Rigid, CONFIG.BRAKE_VALUE_MIN * 255,
                              calculateCombinedForce(state.brake, state.airSpeedKmh), 0, 0, 0, 0, 0}
            }
        end
    end
end

local function handleRightTrigger()
    local isWheelSlip = state.wheelSlip > 10 and 1 or 0

    if isWheelSlip == 1 and state.throttle > 0.1 and CONFIG.ENABLE_THROTTLE_SLIP then
        return {
            type = Triggers.InstructionType.TriggerUpdate,
            parameters = {CONFIG.CONTROLLER_INDEX, Triggers.Trigger.Right, Triggers.TriggerMode.CustomTriggerValue,
                          Triggers.CustomTriggerValueMode.VibratePulse, 255, 255, 3, 50, 0, 0, 0}
        }
    else
        return {
            type = Triggers.InstructionType.TriggerUpdate,
            parameters = {CONFIG.CONTROLLER_INDEX, Triggers.Trigger.Right, Triggers.TriggerMode.CustomTriggerValue,
                          Triggers.CustomTriggerValueMode.Rigid, CONFIG.THROTTLE_RESISTANCE_START, 0, 0, 0, 0, 0, 0}
        }
    end
end

local function handleRGB()
    if state.isBlinking and CONFIG.ENABLE_DAMAGE_LED then
        local currentTime = socket.gettime()
        local timeSinceStart = currentTime - state.blinkStartTime

        if currentTime - state.lastBlinkChange >= CONFIG.DAMAGE_BLINK_DURATION then
            state.lastBlinkChange = currentTime
            state.blinkState = not state.blinkState
            if state.blinkState == false then
                state.blinkCount = state.blinkCount + 1
            end
        end

        if state.blinkCount >= CONFIG.DAMAGE_BLINK_COUNT then
            state.isBlinking = false
            state.blinkCount = 0
            return {
                type = Triggers.InstructionType.RGBUpdate,
                parameters = {0, 0, 0, 0, 0, 0}
            }
        end

        return {
            type = Triggers.InstructionType.RGBUpdate,
            parameters = {0, state.blinkState and CONFIG.DAMAGE_LED_COLOR.r or 0,
                          state.blinkState and CONFIG.DAMAGE_LED_COLOR.g or 0,
                          state.blinkState and CONFIG.DAMAGE_LED_COLOR.b or 0, 0, 0}
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
    if currentTime - state.lastUpdateTime < UPDATE_INTERVAL then
        return
    end
    state.lastUpdateTime = currentTime

    local instructions = {}

    if not state.isBlinking and state.beamDamage > state.lastBeamDamage and (state.beamDamage - state.lastBeamDamage) >=
        CONFIG.DAMAGE_THRESHOLD then
        state.isBlinking = true
        state.blinkStartTime = socket.gettime()
        state.lastBlinkChange = state.blinkStartTime
        state.blinkState = true
        state.blinkCount = 0
    end
    state.lastBeamDamage = state.beamDamage

    table.insert(instructions, handleLeftTrigger())
    table.insert(instructions, handleRightTrigger())
    table.insert(instructions, handleLED())
    table.insert(instructions, handleRGB())

    send({
        instructions = instructions
    })
end

local function updateGFX(dt)
    if not playerInfo.firstPlayerSeated then
        return
    end

    local wheelSlip = 0
    for i = 0, wheels.wheelRotatorCount - 1 do
        local wd = wheels.wheelRotators[i]
        wheelSlip = math.max(wheelSlip, wd.lastSlip)
    end

    local engineLoad = electrics.values.engineLoad or electrics.values.throttle or 0

    local engines = powertrain.getDevicesByCategory("engine")
    local maxRPM = 999999

    if #engines > 0 then
        maxRPM = engines[1]:getTorqueData().maxRPM
    end

    local isAbsActive = electrics.values.absActive == 1
    local rpm = electrics.values.rpm or 0

    if isAbsActive and not state.isABSActive then
        state.absActivationTime = socket.gettime()
    end

    state.throttle = input.state.throttle.val
    state.brake = input.state.brake.val
    state.isABSActive = isAbsActive
    state.airSpeedKmh = electrics.values.airspeed * 3.6
    state.beamDamage = beamstate.damage
    state.wheelSlip = wheelSlip
    state.engineLoad = engineLoad
    state.rpm = rpm
    state.maxRPM = maxRPM

    handleVehicleData()
end

local M = {}
M.updateGFX = updateGFX

return M
