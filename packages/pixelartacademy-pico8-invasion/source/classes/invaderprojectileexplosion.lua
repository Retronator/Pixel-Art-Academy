InvaderProjectileExplosion = {
  sprite = Sprite:new(21, 1, 1)
}
InvaderProjectileExplosion.__index = InvaderProjectileExplosion
setmetatable(InvaderProjectileExplosion, { __index = Entity })

function InvaderProjectileExplosion:new(x, y)
  local invaderProjectileExplosion = setmetatable({}, InvaderProjectileExplosion)

  invaderProjectileExplosion.x = x
  invaderProjectileExplosion.y = y

  sfx(3)

  return invaderProjectileExplosion;
end
