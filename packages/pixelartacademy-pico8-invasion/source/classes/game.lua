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

function Game:isGameplayActive()
  if Game.design.postponeGameplay == DesignOptions.PostponeGameplay.UntilSpawnedAll and not invaders.spawnedAll then return false end
  if scene.defender ~= nil and not scene.defender.alive then return false end
  return true
end

function Game:increaseScore(amount)
  self.score = self.score + amount
end

function Game:update()
  -- Spawn defender.
  if scene.defender == nil and self:isGameplayActive() then
    scene:addDefender()
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
        sfx(12)

        -- Report the score.
        poke(0x5f83, self.score)
      end
    end
  end

  -- Progress level.
  if invaders.aliveCount == 0 and scene.defender.alive then
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
