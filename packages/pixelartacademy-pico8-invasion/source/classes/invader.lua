Invader = {}
Invader.__index = Invader
setmetatable(Invader, { __index = Entity })

function Invader:new(x, y)
  local invader = setmetatable({}, Invader)

  invader.x = x
  invader.y = y
  invader.sprite = Sprite:new(2, 2, 2)

  return invader;
end

function Invader:update()
end

function Invader:draw()
  self.sprite:draw(self.x, self.y)
end
