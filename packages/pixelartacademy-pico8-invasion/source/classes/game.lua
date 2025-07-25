Game = {}
Game.__index = Game

function Game:new()
  local game = setmetatable({}, Game)

  game.lives = Game.design.lives
  game.score = 0
  game.level = 1

  game.deathDuration = 0
  game.levelDuration = 0

  return game
end

function Game:designHasEntity(entity)
  for availableEntity in all(Game.design.entities) do
    if availableEntity == entity then
      return true
    end
  end
  return false
end

function Game:isGameplayActive()
  if Game.design.hasInvader and Game.design.postponeGameplay == DesignOptions.PostponeGameplay.UntilSpawnedAll and not invaders.spawnedAll then return false end
  if scene.defender ~= nil and not scene.defender.alive then return false end
  return true
end

function Game:increaseScore(amount)
  self.score = self.score + amount
end

function Game:invadersWin()
  self.lives = 0
  if scene.defender ~= nil then
    scene.defender:die(scene.defender.x, scene.defender.y)
  end
  self:over()
end

function Game:over()
  sfx(12)

  -- Report the score.
  poke2(0x5f83, self.score)
end

function Game:update()
  -- Spawn defender.
  if scene.defender == nil and self:isGameplayActive() and Game.design.hasDefender then
    scene:addDefender()
    -- Return for a frame to prevent immediate firing.
    return
  end

  -- Respawn defender.
  if scene.defender ~= nil and not scene.defender.alive and self.lives > 0 then
    game.deathDuration = game.deathDuration + dt

    if game.deathDuration > 2 then
      game.deathDuration = 0
      self.lives = self.lives - 1

      if self.lives > 0 then
        scene:addDefender()
      else
        self:over()
      end
    end
  end

  -- Progress level.
  if invaders.aliveCount == 0 and invaders.spawnedAll and scene.defender and scene.defender.alive then
    game.levelDuration = game.levelDuration + dt
    if game.levelDuration > 2 then
      -- Report the level was completed.
      poke(0x5f82, self.level)

      game.levelDuration = 0
      self.level = self.level + 1
      scene = Scene:new()
      invaders = Invaders:new()
    end
  end

  invaders:update()
  scene:update()
end
