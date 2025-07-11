DefenderProjectileExplosion = {
  sprite = Sprite:new(20, 1, 1)
}
DefenderProjectileExplosion.__index = DefenderProjectileExplosion
setmetatable(DefenderProjectileExplosion, { __index = Entity })

function DefenderProjectileExplosion:new(x, y)
  local defenderProjectileExplosion = setmetatable({}, DefenderProjectileExplosion)

  defenderProjectileExplosion.x = x
  defenderProjectileExplosion.y = y

  return defenderProjectileExplosion;
end
