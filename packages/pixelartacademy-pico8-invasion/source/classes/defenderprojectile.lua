DefenderProjectile = {}
DefenderProjectile.__index = DefenderProjectile

function DefenderProjectile:new(x, y)
  local defenderProjectile = setmetatable({}, DefenderProjectile)

  defenderProjectile.x = x
  defenderProjectile.y = y
  defenderProjectile.sprite = Sprite:new(4, 1, 1)

  return defenderProjectile;
end

function DefenderProjectile:isInPlayfield()
  return self.sprite:isInPlayfield(self.x, self.y)
end

function DefenderProjectile:update()
  if gameDesign.defenderProjectileMovement == DesignOptions.DefenderProjectileMovement.Up then
    self.y = self.y - gameDesign.defenderProjectileSpeed * dt

  elseif gameDesign.defenderProjectileMovement == DesignOptions.DefenderProjectileMovement.Down then
    self.y = self.y + gameDesign.defenderProjectileSpeed * dt

  elseif gameDesign.defenderProjectileMovement == DesignOptions.DefenderProjectileMovement.Left then
    self.x = self.x - gameDesign.defenderProjectileSpeed * dt

  elseif gameDesign.defenderProjectileMovement == DesignOptions.DefenderProjectileMovement.Right then
    self.x = self.x + gameDesign.defenderProjectileSpeed * dt

  end
end

function DefenderProjectile:draw()
  self.sprite:draw(self.x, self.y)
end
