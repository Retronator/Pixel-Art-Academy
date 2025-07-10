Shield = {
  sprite = Sprite:new(6, 3, 3)
}
Shield.__index = Shield
setmetatable(Shield, { __index = Entity })

function Shield:new(x, y)
  local shield = setmetatable({}, Shield)

  shield.x = x
  shield.y = y
  shield.mask = Mask:new(Shield.sprite)

  return shield;
end

function Shield:overlaps(entity)
  return entity.sprite:overlaps(entity.x, entity.y, self.sprite, self.x, self.y, self.mask)
end

function Shield:hit(entity)
  local originX = self.x - flr((Shield.sprite.bounds.width - 1) / 2)
  local originY = self.y - flr((Shield.sprite.bounds.height - 1) / 2)
  self.mask:removeSprite(originX, originY, entity.sprite, entity.x, entity.y)
end

function Entity:draw()
  self.sprite:draw(self.x, self.y, self.mask)
end
