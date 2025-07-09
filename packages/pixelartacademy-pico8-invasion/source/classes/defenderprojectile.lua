DefenderProjectile = {
  sprite = Sprite:new(4, 1, 1)
}
DefenderProjectile.__index = DefenderProjectile
setmetatable(DefenderProjectile, { __index = Entity })

function DefenderProjectile:new(x, y)
  local defenderProjectile = setmetatable({}, DefenderProjectile)

  defenderProjectile.x = x
  defenderProjectile.y = y

  return defenderProjectile;
end

function DefenderProjectile:isInPlayfield()
  return self.sprite:isInPlayfield(self.x, self.y)
end

function DefenderProjectile:update()
  if game.design.defenderProjectiles.movement == DesignOptions.DefenderProjectiles.Movement.Up then
    self.y = self.y - game.design.defenderProjectiles.speed * dt

  elseif game.design.defenderProjectiles.movement == DesignOptions.DefenderProjectiles.Movement.Down then
    self.y = self.y + game.design.defenderProjectiles.speed * dt

  elseif game.design.defenderProjectiles.movement == DesignOptions.DefenderProjectiles.Movement.Left then
    self.x = self.x - game.design.defenderProjectiles.speed * dt

  elseif game.design.defenderProjectiles.movement == DesignOptions.DefenderProjectiles.Movement.Right then
    self.x = self.x + game.design.defenderProjectiles.speed * dt

  end
end

function DefenderProjectile:draw()
  self.sprite:draw(self.x, self.y)
end
