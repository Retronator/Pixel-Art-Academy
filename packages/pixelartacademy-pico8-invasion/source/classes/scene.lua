Scene = {}
Scene.__index = Scene

function Scene:new()
  local scene = setmetatable({}, Scene)

  scene.defender = Defender:new(64, 64)
  scene.defenderProjectiles = {}

  scene.invaders = {}
  scene:addInvader(64, 20)

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
        self:removeDefenderProjectile(defenderProjectile)
        self:removeInvader(invader)
        self:addInvader(gameDesign.playfieldBounds.left + rnd(gameDesign.playfieldBounds.width), gameDesign.playfieldBounds.top + rnd(gameDesign.playfieldBounds.height / 2))
      end
    end
  end
end

function Scene:draw()
  clip(gameDesign.playfieldBounds.left, gameDesign.playfieldBounds.top, gameDesign.playfieldBounds.width, gameDesign.playfieldBounds.height)

  self.defender:draw()

  for defenderProjectile in all(self.defenderProjectiles) do
    defenderProjectile:draw()
  end

  for invader in all(self.invaders) do
    invader:draw()
  end

  clip()
end
