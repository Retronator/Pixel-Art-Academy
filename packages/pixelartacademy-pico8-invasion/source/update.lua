dt = 1 / 60

function _update60()
  --sprite update routine
  local updated_pixels_count = peek(0x5f80)
  for i = 0, updated_pixels_count - 1 do
    local x = peek(0x5f81 + i * 3)
    local y = peek(0x5f81 + i * 3 + 1)
    local color = peek(0x5f81 + i * 3 + 2)
    sset(x, y, color)
  end

  if game == nil or game.lives == 0 then
    -- Wait for button to start.
    if btnp(4) or btnp(5) then
      game = Game:new()
      scene = Scene:new()
      invaders = Invaders:new()
    end
  end

  if game ~= nil then
    game:update()
  end
end
