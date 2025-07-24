Defender = {
  sprite = Sprite:new(0, 2, 2)
}
Defender.__index = Defender
setmetatable(Defender, { __index = Entity })

function Defender:new(x, y)
  local defender = setmetatable({}, Defender)

  defender.x = x
  defender.y = y
  defender.alive = true

  return defender;
end

function Defender:die(explosionX, explosionY)
  self.alive = false
  self.sprite:createParticles(self.x, self.y, explosionX, explosionY)
  sfx(4)
end


function Defender:update()
  -- Horizontal movement
  if Game.design.defender.movement == DesignOptions.Defender.Movements.Horizontal or Game.design.defender.movement == DesignOptions.Defender.Movements.AllDirections then
    if btn(0) then
      self.x = self.x - Game.design.defender.speed
    end
    if btn(1) then
      self.x = self.x + Game.design.defender.speed
    end

    self.x = mid(Game.design.playfieldBounds.left + self.sprite.relativeCenterX, self.x, Game.design.playfieldBounds.right - self.sprite.relativeCenterX - 1)
  end

  -- Vertical movement
  if Game.design.defender.movement == DesignOptions.Defender.Movements.Vertical or Game.design.defender.movement == DesignOptions.Defender.Movements.AllDirections then
    if btn(2) then
      self.y = self.y - Game.design.defender.speed
    end
    if btn(3) then
      self.y = self.y + Game.design.defender.speed
    end

    self.y = mid(Game.design.playfieldBounds.top + self.sprite.relativeCenterY, self.y, Game.design.playfieldBounds.bottom - self.sprite.relativeCenterY - 1)
  end
  
  -- Shooting
  if Game.design.hasDefenderProjectile and (btnp(4) or btnp(5)) and #scene.defenderProjectiles < Game.design.defenderProjectiles.maxCount then
    scene:addDefenderProjectile()
    sfx(0)
  end
end
