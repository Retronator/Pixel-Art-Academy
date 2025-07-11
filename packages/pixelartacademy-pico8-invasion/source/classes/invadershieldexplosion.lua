InvaderShieldExplosion = {
  sprite = Sprite:new(54, 1, 1)
}
InvaderShieldExplosion.__index = InvaderShieldExplosion
setmetatable(InvaderShieldExplosion, { __index = Entity })

function InvaderShieldExplosion:new(x, y)
  local invaderShieldExplosion = setmetatable({}, InvaderShieldExplosion)

  invaderShieldExplosion.x = x
  invaderShieldExplosion.y = y

  return invaderShieldExplosion;
end
