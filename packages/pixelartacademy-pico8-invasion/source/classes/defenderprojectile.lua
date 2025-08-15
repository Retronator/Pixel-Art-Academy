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
  if Game.design.defenderProjectiles.direction == Directions.Up then
    self.y = self.y - Game.design.defenderProjectiles.speed

  elseif Game.design.defenderProjectiles.direction == Directions.Down then
    self.y = self.y + Game.design.defenderProjectiles.speed

  elseif Game.design.defenderProjectiles.direction == Directions.Left then
    self.x = self.x - Game.design.defenderProjectiles.speed

  elseif Game.design.defenderProjectiles.direction == Directions.Right then
    self.x = self.x + Game.design.defenderProjectiles.speed
  end
end
