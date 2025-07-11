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
  if Game.design.invaderProjectiles.movement == DesignOptions.InvaderProjectiles.Movement.Up then
    self.y = self.y - Game.design.invaderProjectiles.speed

  elseif Game.design.invaderProjectiles.movement == DesignOptions.InvaderProjectiles.Movement.Down then
    self.y = self.y + Game.design.invaderProjectiles.speed

  elseif Game.design.invaderProjectiles.movement == DesignOptions.InvaderProjectiles.Movement.Left then
    self.x = self.x - Game.design.invaderProjectiles.speed

  elseif Game.design.invaderProjectiles.movement == DesignOptions.InvaderProjectiles.Movement.Right then
    self.x = self.x + Game.design.invaderProjectiles.speed
  end
end
