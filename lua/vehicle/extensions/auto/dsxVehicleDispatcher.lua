local M = {}

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

  local rpm = electrics.values.rpm or 0

  obj:queueGameEngineLua(
    string.format(
      "extensions.hook('dsxUpdate', %f, %f, %s, %f, %f, %f, %f, %f, %f)", 
      input.state.throttle.val, 
      input.state.brake.val, 
      electrics.values.absActive == 1, 
      electrics.values.airspeed * 3.6, 
      beamstate.damage,
      wheelSlip,
      engineLoad,
      rpm,
      maxRPM
    )
  )
end

M.updateGFX = updateGFX

return M