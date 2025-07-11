Scene = {}
Scene.__index = Scene

function Scene:new()
  local scene = setmetatable({}, Scene)

  -- Create the shields.
  scene.shields = {}

  if Game.design.shields.amount > 0 then
    local shieldsX, shieldsY

    if Game.design.shields.side == Sides.Left then
      shieldsX = Game.design.playfieldBounds.left + Defender.sprite.bounds.width * 2 + flr(Shield.sprite.bounds.width / 2)

    elseif Game.design.shields.side == Sides.Right then
      shieldsX = Game.design.playfieldBounds.right - Defender.sprite.bounds.width * 2 - flr(Shield.sprite.bounds.width / 2)

    elseif Game.design.shields.side == Sides.Top then
      shieldsY = Game.design.playfieldBounds.top + Defender.sprite.bounds.height * 2 + flr(Shield.sprite.bounds.height / 2)

    elseif Game.design.shields.side == Sides.Bottom then
      shieldsY = Game.design.playfieldBounds.bottom - Defender.sprite.bounds.height * 2 - flr(Shield.sprite.bounds.height / 2)
    end

    if Game.design.shields.side == Sides.Left or Game.design.shields.side == Sides.Right then
      local span = Game.design.shields.amount * Shield.sprite.bounds.height + (Game.design.shields.amount - 1) * Game.design.shields.spacing
      local top = Game.design.playfieldBounds.top + flr(Game.design.playfieldBounds.height / 2) - ceil(span / 2) + flr(Shield.sprite.bounds.height / 2)

      for shieldNumber = 1, Game.design.shields.amount do
        local shieldY = top + (shieldNumber - 1) * (Shield.sprite.bounds.height + Game.design.shields.spacing)
        add(scene.shields, Shield:new(shieldsX, shieldY))
      end

    else
      local span = Game.design.shields.amount * Shield.sprite.bounds.width + (Game.design.shields.amount - 1) * Game.design.shields.spacing
      local left = Game.design.playfieldBounds.left + flr(Game.design.playfieldBounds.width / 2) - ceil(span / 2) + flr(Shield.sprite.bounds.width / 2)

      for shieldNumber = 1, Game.design.shields.amount do
        local shieldX = left + (shieldNumber - 1) * (Shield.sprite.bounds.width + Game.design.shields.spacing)
        add(scene.shields, Shield:new(shieldX, shieldsY))
      end
    end
  end

  -- Create dynamic lists.
  scene.defenderProjectiles = {}
  scene.invaderProjectiles = {}
  scene.explosions = {}
  scene.invaders = {}
  scene.particles = {}

  return scene
end

function Scene:addDefender()
  local defenderX, defenderY

  if Game.design.defender.horizontalAlignment == HorizontalAlignment.Left then
    defenderX = Game.design.playfieldBounds.left + Defender.sprite.bounds.width

  elseif Game.design.defender.horizontalAlignment == HorizontalAlignment.Right then
    defenderX = Game.design.playfieldBounds.right - Defender.sprite.bounds.width

  else
    defenderX = Game.design.playfieldBounds.left + flr(Game.design.playfieldBounds.width / 2)
  end

  if Game.design.defender.verticalAlignment == VerticalAlignment.Top then
    defenderY = Game.design.playfieldBounds.top + Defender.sprite.bounds.height

  elseif Game.design.defender.verticalAlignment == VerticalAlignment.Bottom then
    defenderY = Game.design.playfieldBounds.bottom - Defender.sprite.bounds.height

  else
    defenderY = Game.design.playfieldBounds.top + flr(Game.design.playfieldBounds.height / 2)
  end

  scene.defender = Defender:new(defenderX, defenderY)
end

function Scene:addDefenderProjectile()
  local x = self.defender.x
  local y = self.defender.y

  if Game.design.defenderProjectiles.movement == Directions.Up then
    local top = self.defender.y - Defender.sprite.centerY + Defender.sprite.bounds.top
    y = top - DefenderProjectile.sprite.bounds.top + DefenderProjectile.sprite.centerY

  elseif Game.design.defenderProjectiles.movement == Directions.Down then
    local bottom = self.defender.y - Defender.sprite.centerY + Defender.sprite.bounds.bottom
    y = bottom - DefenderProjectile.sprite.bounds.bottom + DefenderProjectile.sprite.centerY

  elseif Game.design.defenderProjectiles.movement == Directions.Left then
    local left = self.defender.x - Defender.sprite.centerX + Defender.sprite.bounds.left
    x = left - DefenderProjectile.sprite.bounds.left + DefenderProjectile.sprite.centerX

  elseif Game.design.defenderProjectiles.movement == Directions.Right then
    local right = self.defender.x - Defender.sprite.centerX + Defender.sprite.bounds.right
    x = right - DefenderProjectile.sprite.bounds.right + DefenderProjectile.sprite.centerX
  end

  local defenderProjectile = DefenderProjectile:new(x, y)
  add(self.defenderProjectiles, defenderProjectile)
end

function Scene:addInvaderProjectile(invader)
  local invaderProjectile = InvaderProjectile:new(invader.x, invader.y)
  add(self.invaderProjectiles, invaderProjectile)
end

function Scene:removeDefenderProjectile(defenderProjectile)
  del(self.defenderProjectiles, defenderProjectile)
end

function Scene:removeInvaderProjectile(invaderProjectile)
  del(self.invaderProjectiles, invaderProjectile)
end

function Scene:addInvader(x, y)
  local invader = Invader:new(x, y)
  add(self.invaders, invader)
  return invader
end

function Scene:removeInvader(invader)
  del(self.invaders, invader)
end

function Scene:addParticle(x, y, color, explosionX, explosionY)
  local particle = Particle:new(x, y, color, explosionX, explosionY)
  add(self.particles, particle)
end

function Scene:addDefenderProjectileExplosion(x, y)
  local explosion = DefenderProjectileExplosion:new(x, y)
  add(self.explosions, explosion)
  return explosion
end

function Scene:addInvaderProjectileExplosion(x, y)
  local explosion = InvaderProjectileExplosion:new(x, y)
  add(self.explosions, explosion)
  return explosion
end

function Scene:update()
  if self.defender ~= nil and self.defender.alive then
    self.defender:update()
  end

  -- Remove all explosions.
  for index = #self.explosions, 1, -1 do
    self.explosions[index] = nil
  end

  -- Update projectile positions.
  for defenderProjectile in all(self.defenderProjectiles) do
    defenderProjectile:update()
    if not defenderProjectile:isInPlayfield() then
      self:removeDefenderProjectile(defenderProjectile)
    end
  end

  for invaderProjectile in all(self.invaderProjectiles) do
    invaderProjectile:update()
    if not invaderProjectile:isInPlayfield() then
      del(self.invaderProjectiles, invaderProjectile)
    end
  end

  -- Check for collisions.
  for defenderProjectile in all(self.defenderProjectiles) do
    for invader in all(self.invaders) do
      local overlaps, explosionX, explosionY = defenderProjectile:overlaps(invader)
      if overlaps then
        invader:die(explosionX, explosionY)
        self:removeDefenderProjectile(defenderProjectile)
        self:removeInvader(invader)
        self:addDefenderProjectileExplosion(explosionX, explosionY)
      end
    end

    for invaderProjectile in all(self.invaderProjectiles) do
      local overlaps, explosionX, explosionY = defenderProjectile:overlaps(invaderProjectile)
      if overlaps then
        self:removeDefenderProjectile(defenderProjectile)
        self:removeInvaderProjectile(invaderProjectile)
        self:addDefenderProjectileExplosion(explosionX, explosionY)
        self:addInvaderProjectileExplosion(explosionX, explosionY)
        defenderProjectile.sprite:createParticles(defenderProjectile.x, defenderProjectile.y, explosionX, explosionY)
        invaderProjectile.sprite:createParticles(invaderProjectile.x, invaderProjectile.y, explosionX, explosionY)
      end
    end

    for shield in all(self.shields) do
      local overlaps, explosionX, explosionY = shield:overlaps(defenderProjectile)
      if overlaps then
        self:removeDefenderProjectile(defenderProjectile)
        explosion = self:addDefenderProjectileExplosion(explosionX, explosionY)
        shield:hit(explosion)
      end
    end
  end

  for invaderProjectile in all(self.invaderProjectiles) do
    if self.defender ~= nil and self.defender.alive then
      local overlaps, explosionX, explosionY = invaderProjectile:overlaps(self.defender)
      if overlaps then
        self.defender:die(explosionX, explosionY)
        self:removeInvaderProjectile(invaderProjectile)
        self:addInvaderProjectileExplosion(explosionX, explosionY)
      end
    end

    for shield in all(self.shields) do
      local overlaps, explosionX, explosionY = shield:overlaps(invaderProjectile)
      if overlaps then
        self:removeInvaderProjectile(invaderProjectile)
        explosion = self:addInvaderProjectileExplosion(explosionX, explosionY)
        shield:hit(explosion)
      end
    end
  end  

  for invader in all(self.invaders) do
    if self.defender ~= nil and self.defender.alive then
      local overlaps, explosionX, explosionY = invader:overlaps(self.defender)
      if overlaps then
        self.defender:die(explosionX, explosionY)
        invader:die(explosionX, explosionY)
        self:removeInvader(invader)
      end
    end

    for shield in all(self.shields) do
      local overlaps, explosionX, explosionY = shield:overlaps(invader)
      if overlaps then
        explosion = InvaderShieldExplosion:new(explosionX, explosionY)
        shield:hit(explosion)
      end
    end
  end

  -- Move particles.
  for particle in all(self.particles) do
    particle:update()
    if particle.x < Game.design.playfieldBounds.left or particle.x > Game.design.playfieldBounds.right or particle.y < Game.design.playfieldBounds.top or particle.y > Game.design.playfieldBounds.bottom then
      del(self.particles, particle)
    end
  end
end

function Scene:draw()
  clip(Game.design.playfieldBounds.left, Game.design.playfieldBounds.top, Game.design.playfieldBounds.width, Game.design.playfieldBounds.height)

  for defenderProjectile in all(self.defenderProjectiles) do
    defenderProjectile:draw()
  end

  for invaderProjectile in all(self.invaderProjectiles) do
    invaderProjectile:draw()
  end

  if self.defender ~= nil and self.defender.alive then
    self.defender:draw()
  end

  for invader in all(self.invaders) do
    invader:draw()
  end

  for shield in all(self.shields) do
    shield:draw()
  end

  for particle in all(self.particles) do
    if pget(particle.x, particle.y) > 0 then
      del(self.particles, particle)
    else
      particle:draw()
    end
  end

  for explosion in all(self.explosions) do
    explosion:draw()
  end

  clip()
end
