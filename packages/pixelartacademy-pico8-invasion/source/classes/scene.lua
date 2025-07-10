Scene = {}
Scene.__index = Scene

function Scene:new()
  local scene = setmetatable({}, Scene)

  -- Create the defender.
  local defenderX, defenderY

  if game.design.defender.horizontalAlignment == HorizontalAlignment.Left then
    defenderX = game.design.playfieldBounds.left + Defender.sprite.bounds.width

  elseif game.design.defender.horizontalAlignment == HorizontalAlignment.Right then
    defenderX = game.design.playfieldBounds.right - Defender.sprite.bounds.width

  else
    defenderX = game.design.playfieldBounds.left + flr(game.design.playfieldBounds.width / 2)
    
  end

  if game.design.defender.verticalAlignment == VerticalAlignment.Top then
    defenderY = game.design.playfieldBounds.top + Defender.sprite.bounds.height

  elseif game.design.defender.verticalAlignment == VerticalAlignment.Bottom then
    defenderY = game.design.playfieldBounds.bottom - Defender.sprite.bounds.height

  else
    defenderY = game.design.playfieldBounds.top + flr(game.design.playfieldBounds.height / 2)

  end

  scene.defender = Defender:new(defenderX, defenderY)

  -- Create the shields.
  scene.shields = {}

  if game.design.shields.amount > 0 then
    local shieldsX, shieldsY

    if game.design.shields.side == Sides.Left then
      shieldsX = game.design.playfieldBounds.left + Defender.sprite.bounds.width * 2 + flr(Shield.sprite.bounds.width / 2)

    elseif game.design.shields.side == Sides.Right then
      shieldsX = game.design.playfieldBounds.right - Defender.sprite.bounds.width * 2 - flr(Shield.sprite.bounds.width / 2)

    elseif game.design.shields.side == Sides.Top then
      shieldsY = game.design.playfieldBounds.top + Defender.sprite.bounds.height * 2 + flr(Shield.sprite.bounds.height / 2)

    elseif game.design.shields.side == Sides.Bottom then
      shieldsY = game.design.playfieldBounds.bottom - Defender.sprite.bounds.height * 2 - flr(Shield.sprite.bounds.height / 2)

    end

    if game.design.shields.side == Sides.Left or game.design.shields.side == Sides.Right then
      local span = game.design.shields.amount * Shield.sprite.bounds.height + (game.design.shields.amount - 1) * game.design.shields.spacing
      local top = game.design.playfieldBounds.top + flr(game.design.playfieldBounds.height / 2) - ceil(span / 2) + flr(Shield.sprite.bounds.height / 2)

      for shieldNumber = 1, game.design.shields.amount do
        local shieldY = top + (shieldNumber - 1) * (Shield.sprite.bounds.height + game.design.shields.spacing)
        add(scene.shields, Shield:new(shieldsX, shieldY))
      end

    else
      local span = game.design.shields.amount * Shield.sprite.bounds.width + (game.design.shields.amount - 1) * game.design.shields.spacing
      local left = game.design.playfieldBounds.left + flr(game.design.playfieldBounds.width / 2) - ceil(span / 2) + flr(Shield.sprite.bounds.width / 2)

      for shieldNumber = 1, game.design.shields.amount do
        local shieldX = left + (shieldNumber - 1) * (Shield.sprite.bounds.width + game.design.shields.spacing)
        add(scene.shields, Shield:new(shieldX, shieldsY))
      end
    end
  end

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

    for shield in all(self.shields) do
      if shield:overlaps(defenderProjectile) then
        self:removeDefenderProjectile(defenderProjectile)
        shield:hit(defenderProjectile)
      end
    end
  end
end

function Scene:draw()
  clip(game.design.playfieldBounds.left, game.design.playfieldBounds.top, game.design.playfieldBounds.width, game.design.playfieldBounds.height)

  for defenderProjectile in all(self.defenderProjectiles) do
    defenderProjectile:draw()
  end

  self.defender:draw()

  for invader in all(self.invaders) do
    invader:draw()
  end

  for shield in all(self.shields) do
    shield:draw()
  end

  clip()
end
