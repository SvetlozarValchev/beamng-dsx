local M = {}

local function updateGFX(dt)
  if not playerInfo.firstPlayerSeated then
    return
  end

  -- for i = 0, wheels.wheelRotatorCount - 1 do
  --   local wd = wheels.wheelRotators[i]

  --   print("====================================================================")
  --   print_table(wd)
  -- end

  obj:queueGameEngineLua(string.format("extensions.hook('dsxUpdate', %f, %f, %s, %f, %f)", input.state.throttle.val, input.state.brake.val, electrics.values.absActive == 1, electrics.values.airspeed * 3.6, beamstate.damage))
end

M.updateGFX = updateGFX

return M
