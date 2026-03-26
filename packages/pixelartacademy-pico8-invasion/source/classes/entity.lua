Entity = {}

function Entity:overlaps(entity)
  return self.sprite:overlaps(self.x, self.y, entity.sprite, entity.x, entity.y)
end

function Entity:draw()
  self.sprite:draw(self.x, self.y)
end
