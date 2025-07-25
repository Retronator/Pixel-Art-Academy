ShieldExplosion = {
  sprite = Sprite:new(54, 1, 1)
}
ShieldExplosion.__index = ShieldExplosion
setmetatable(ShieldExplosion, { __index = Entity })

function ShieldExplosion:new(x, y)
  local shieldExplosion = setmetatable({}, ShieldExplosion)

  shieldExplosion.x = x
  shieldExplosion.y = y

  return shieldExplosion;
end
