Scene = {}
Scene.__index = Scene

function Scene:new()
  local scene = setmetatable({}, Scene)

  local defenderX, defenderY

  if game.design.invaders.attackDirection == Directions.Left then
    defenderX = game.design.playfieldBounds.left + Defender.sprite.bounds.width

  elseif game.design.invaders.attackDirection == Directions.Right then
    defenderX = game.design.playfieldBounds.right - Defender.sprite.bounds.width

  else
    defenderX = game.design.playfieldBounds.left + flr(game.design.playfieldBounds.width / 2)
    
  end

  if game.design.invaders.attackDirection == Directions.Up then
    defenderY = game.design.playfieldBounds.top + Defender.sprite.bounds.height

  elseif game.design.invaders.attackDirection == Directions.Down then
    defenderY = game.design.playfieldBounds.bottom - Defender.sprite.bounds.height

  else
    defenderY = game.design.playfieldBounds.top + flr(game.design.playfieldBounds.height / 2)

  end

  scene.defender = Defender:new(defenderX, defenderY)

  scene.defenderProjectiles = {}
  scene.invaders = {}

  return scene
end

function Scene:addDefenderProjectile()
  local defenderProjectile = DefenderProjectile:new(self.defender.x, self.defender.y)
  add(self.defenderProjectiles, defenderProjectile)
end

function Scene:removeDefenderProjectile(defenderProjectile)
  del(self.defenderProjectiles, defenderProjectile)
end

function Scene:addInvader(x, y)
  local invader = Invader:new(x, y)
  add(self.invaders, invader)
  return invader
end

function Scene:removeInvader(invader)
  del(self.invaders, invader)
end

function Scene:update()
  self.defender:update()

  -- Update projectile positions.
  for defenderProjectile in all(self.defenderProjectiles) do
    defenderProjectile:update()
    if not defenderProjectile:isInPlayfield() then
      self:removeDefenderProjectile(defenderProjectile)
    end
  end

  -- Check for collisions.
  for defenderProjectile in all(self.defenderProjectiles) do
    for invader in all(self.invaders) do
      if defenderProjectile:overlaps(invader) then
        invader:die()
        self:removeDefenderProjectile(defenderProjectile)
        self:removeInvader(invader)
      end
    end
  end
end

function Scene:draw()
  clip(game.design.playfieldBounds.left, game.design.playfieldBounds.top, game.design.playfieldBounds.width, game.design.playfieldBounds.height)

  self.defender:draw()

  for defenderProjectile in all(self.defenderProjectiles) do
    defenderProjectile:draw()
  end

  for invader in all(self.invaders) do
    invader:draw()
  end

  clip()
end
