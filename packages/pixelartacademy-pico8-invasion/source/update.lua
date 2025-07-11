dt = 1 / 60

function _update60()
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
