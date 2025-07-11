Invader = {
  sprite = Sprite:new(2, 2, 2)
}
Invader.__index = Invader
setmetatable(Invader, { __index = Entity })

function Invader:new(x, y)
  local invader = setmetatable({}, Invader)

  invader.x = x
  invader.y = y
  invader.alive = true

  return invader;
end

function Invader:moveBy(x, y)
  self.x = self.x + x
  self.y = self.y + y
end

function Invader:moveTo(x, y)
  self.x = x
  self.y = y
end

function Invader:die(explosionX, explosionY)
  self.alive = false
  self.sprite:createParticles(self.x, self.y, explosionX, explosionY)
  game:increaseScore(Game.design.invaders.scorePerInvader)
  sfx(5)
end
