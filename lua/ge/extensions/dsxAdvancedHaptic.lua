local socket = require("socket")
local Triggers = require("dsxTriggerEnum")

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
}

local function packetToJson(packet)
  return jsonEncode(packet)
end

local function send(data)
  local jsonData = packetToJson(data)
  udp:sendto(jsonData, address, port)
end

-- modified lerp with bias toward 'a'
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
  local startOfResistanceBrake = 1 * lerp(0.4, 1, state.brake)
  local startOfResistance = lerp(25, 175, startOfResistanceBrake)
  local airSpeed = math.min(100, inverseLerp(0, 100, state.airSpeedKmh))
  local amountOfForceExcerted = math.min(255, lerp(50, 255, airSpeed))

  if not state.isABSActive then
    return {
      type = Triggers.InstructionType.TriggerUpdate,
      parameters = {
        0,
        Triggers.Trigger.Left,
        Triggers.TriggerMode.CustomTriggerValue,
        Triggers.CustomTriggerValueMode.Rigid,
        startOfResistance,
        amountOfForceExcerted,
        255,
        0,
        0,
        0,
        0
      }
    }
  else
    return {
      type = Triggers.InstructionType.TriggerUpdate,
      parameters = {
        0,
        Triggers.Trigger.Left,
        Triggers.TriggerMode.CustomTriggerValue,
        Triggers.CustomTriggerValueMode.VibrateResistanceAB,
        255,
        255,
        255,
        255,
        255,
        255,
        10
      }
    }
  end
end

local function handleRightTrigger()
  local startOfResistanceThrottle = 1 * lerp(0.4, 1, state.throttle)
  local startOfResistance = lerp(50, 175, startOfResistanceThrottle)
  local totalForceExcerted = 25

  return {
    type = Triggers.InstructionType.TriggerUpdate,
    parameters = {
      0,
      Triggers.Trigger.Right,
      Triggers.TriggerMode.CustomTriggerValue,
      Triggers.CustomTriggerValueMode.Rigid,
      startOfResistance,
      totalForceExcerted,
      255,
      0,
      0,
      0,
      0
    }
  }
end

local function handleVehicleData()
  local instructions = {}

  table.insert(instructions, handleLeftTrigger())
  table.insert(instructions, handleRightTrigger())

  send(
    {
      instructions = instructions
    }
  )
end

local function dsxAdvancedUpdate(throttle, brake, isABSActive, airSpeedKmh, beamDamage)
  state.throttle = throttle
  state.brake = brake
  state.isABSActive = isABSActive
  state.airSpeedKmh = airSpeedKmh
  state.beamDamage = beamDamage

  handleVehicleData()
end

M.dsxAdvancedUpdate = dsxAdvancedUpdate
return M
