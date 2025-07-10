Defender = {
  sprite = Sprite:new(0, 2, 2)
}
Defender.__index = Defender
setmetatable(Defender, { __index = Entity })

function Defender:new(x, y)
  local defender = setmetatable({}, Defender)

  defender.x = x
  defender.y = y

  return defender;
end

function Defender:update()
  -- Horizontal movement
  if game.design.defender.movement == DesignOptions.Defender.Movement.Horizontal or game.design.defender.movement == DesignOptions.Defender.Movement.AllDirections then
    if btn(0) then
      self.x = self.x - game.design.defender.speed
    end
    if btn(1) then
      self.x = self.x + game.design.defender.speed
    end

    self.x = mid(game.design.playfieldBounds.left + self.sprite.relativeCenterX, self.x, game.design.playfieldBounds.right - self.sprite.relativeCenterX - 1)
  end

  -- Vertical movement
  if game.design.defender.movement == DesignOptions.Defender.Movement.Vertical or game.design.defender.movement == DesignOptions.Defender.Movement.AllDirections then
    if btn(2) then
      self.y = self.y - game.design.defender.speed
    end
    if btn(3) then
      self.y = self.y + game.design.defender.speed
    end

    self.y = mid(game.design.playfieldBounds.top + self.sprite.relativeCenterY, self.y, game.design.playfieldBounds.bottom - self.sprite.relativeCenterY - 1)
  end
  
  -- Shooting
  if (btnp(4) or btnp(5)) and #scene.defenderProjectiles < game.design.defenderProjectiles.maxCount then
    scene:addDefenderProjectile()
  end
end

function Defender:draw()
  self.sprite:draw(self.x, self.y)
end
