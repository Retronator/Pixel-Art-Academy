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

  if Game.design.invaders.formation.attackDirection == Directions.Left and self.x - self.sprite.relativeCenterX < Game.design.playfieldBounds.left or
      Game.design.invaders.formation.attackDirection == Directions.Right and self.x - self.sprite.relativeCenterX + self.sprite.bounds.width > Game.design.playfieldBounds.right or
      Game.design.invaders.formation.attackDirection == Directions.Up and self.y - self.sprite.relativeCenterY < Game.design.playfieldBounds.top or
      Game.design.invaders.formation.attackDirection == Directions.Down and self.y - self.sprite.relativeCenterY + self.sprite.bounds.height > Game.design.playfieldBounds.bottom then

    game:invadersWin()
  end
end

function Invader:die(explosionX, explosionY)
  self.alive = false

  if Game.design.invaders.deathType == DeathTypes.Explode then
    self.sprite:createParticles(self.x, self.y, explosionX, explosionY)
  end

  game:increaseScore(Game.design.invaders.scorePerInvader + (game.level - 1) * Game.design.invaders.scoreIncreasePerInvaderPerLevel)
  sfx(5)
end
