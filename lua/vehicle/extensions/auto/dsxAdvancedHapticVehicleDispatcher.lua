local M = {}

local function updateGFX(dt)
  if not playerInfo.firstPlayerSeated then
    return
  end

  obj:queueGameEngineLua(string.format("extensions.hook('dsxAdvancedUpdate', %f, %f, %s, %f, %f)", input.state.throttle.val, input.state.brake.val, electrics.values.absActive == 1, electrics.values.airspeed * 3.6, beamstate.damage))
end

M.updateGFX = updateGFX

return M
