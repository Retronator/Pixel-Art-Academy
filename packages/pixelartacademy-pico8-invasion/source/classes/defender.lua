Defender = {}
Defender.__index = Defender

function Defender:new(x, y)
  local defender = setmetatable({}, Defender)

  defender.x = x
  defender.y = y
  defender.sprite = Sprite:new(0, 2, 2)
  defender.projectiles = {}

  return defender;
end

function Defender:update()
  -- Horizontal movement
  if gameDesign.defenderMovement == DesignOptions.DefenderMovement.Horizontal or gameDesign.defenderMovement == DesignOptions.DefenderMovement.AllDirections then
    if btn(0) then
      self.x = self.x - gameDesign.defenderSpeed * dt
    end
    if btn(1) then
      self.x = self.x + gameDesign.defenderSpeed * dt
    end

    self.x = mid(gameDesign.playfieldBounds.left + self.sprite.relativeCenterX, self.x, gameDesign.playfieldBounds.right - self.sprite.relativeCenterX - 1)
  end

  -- Vertical movement
  if gameDesign.defenderMovement == DesignOptions.DefenderMovement.Vertical or gameDesign.defenderMovement == DesignOptions.DefenderMovement.AllDirections then
    if btn(2) then
      self.y = self.y - gameDesign.defenderSpeed * dt
    end
    if btn(3) then
      self.y = self.y + gameDesign.defenderSpeed * dt
    end

    self.y = mid(gameDesign.playfieldBounds.top + self.sprite.relativeCenterY, self.y, gameDesign.playfieldBounds.bottom - self.sprite.relativeCenterY - 1)
  end
  
  -- Shooting
  if (btnp(4) or btnp(5)) and #scene.defenderProjectiles < gameDesign.defenderProjectilesMaxCount then
    scene:addDefenderProjectile()
  end
end

function Defender:draw()
  self.sprite:draw(self.x, self.y)
end
