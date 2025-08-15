InvaderProjectile = {
  sprite = Sprite:new(5, 1, 1)
}
InvaderProjectile.__index = InvaderProjectile
setmetatable(InvaderProjectile, { __index = Entity })

function InvaderProjectile:new(x, y)
  local invaderProjectile = setmetatable({}, InvaderProjectile)

  invaderProjectile.x = x
  invaderProjectile.y = y

  return invaderProjectile;
end

function InvaderProjectile:isInPlayfield()
  return self.sprite:isInPlayfield(self.x, self.y)
end

function InvaderProjectile:update()
  if Game.design.invaderProjectiles.direction == Directions.Up then
    self.y = self.y - Game.design.invaderProjectiles.speed

  elseif Game.design.invaderProjectiles.direction == Directions.Down then
    self.y = self.y + Game.design.invaderProjectiles.speed

  elseif Game.design.invaderProjectiles.direction == Directions.Left then
    self.x = self.x - Game.design.invaderProjectiles.speed

  elseif Game.design.invaderProjectiles.direction == Directions.Right then
    self.x = self.x + Game.design.invaderProjectiles.speed
  end
end
