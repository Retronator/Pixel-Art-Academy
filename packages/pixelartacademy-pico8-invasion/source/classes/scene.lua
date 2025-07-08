Scene = {}
Scene.__index = Scene

function Scene:new()
  local scene = setmetatable({}, Scene)

  scene.defender = Defender:new(64, 64)
  scene.defenderProjectiles = {}

  return scene
end

function Scene:addDefenderProjectile()
  local defenderProjectile = DefenderProjectile:new(self.defender.x, self.defender.y)
  add(self.defenderProjectiles, defenderProjectile)
end

function Scene:update()
  self.defender:update()

  for defenderProjectile in all(self.defenderProjectiles) do
    defenderProjectile:update()
    if not defenderProjectile:isInPlayfield() then
      del(self.defenderProjectiles, defenderProjectile)
    end
  end
end

function Scene:draw()
  clip(gameDesign.playfieldBounds.left, gameDesign.playfieldBounds.top, gameDesign.playfieldBounds.width, gameDesign.playfieldBounds.height)
  self.defender:draw()

  for defenderProjectile in all(self.defenderProjectiles) do
    defenderProjectile:draw()
  end
  clip()
end
