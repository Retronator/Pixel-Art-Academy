Entity = {}

function Entity:overlaps(entity)
  return self.sprite:overlaps(self.x, self.y, entity.sprite, entity.x, entity.y)
end
