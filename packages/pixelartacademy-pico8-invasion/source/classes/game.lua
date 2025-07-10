Game = {}
Game.__index = Game

function Game:new()
  local game = setmetatable({}, Game)

  game.design = {
    defender = {
      movement = DesignOptions.Defender.Movement.AllDirections,
      horizontalAlignment = HorizontalAlignment.Left,
      verticalAlignment = VerticalAlignment.Bottom,
      speed = 2
    },
    defenderProjectiles = {
      movement = DesignOptions.DefenderProjectiles.Movement.Right,
      speed = 6,
      maxCount = 10
    },
    invaders = {
      formation = {
        rows = 3,
        columns = 3,
        horizontalSpacing = 2,
        verticalSpacing = 2,
        horizontalAlignment = HorizontalAlignment.Center,
        verticalAlignment = VerticalAlignment.Middle,
        movement = DesignOptions.Invaders.Formation.Movement.Individual,
        postponeMovement = DesignOptions.Invaders.Formation.PostponeMovement.UntilSpawnedAll,
        horizontalSpeed = 8,
        verticalSpeed = 1,
        spawnDelay = 0.1
      },
      attackDirection = DesignOptions.Invaders.AttackDirection.Left,
      entry = DesignOptions.Invaders.Entry.Appear,
      attack = DesignOptions.Invaders.Attack.None,
    },
    playfieldBounds = {
      left = 0,
      right = 127,
      top = 8,
      bottom = 124 - Defender.sprite.bounds.height
    }
  }

  game.design.playfieldBounds.width = game.design.playfieldBounds.right - game.design.playfieldBounds.left + 1
  game.design.playfieldBounds.height = game.design.playfieldBounds.bottom - game.design.playfieldBounds.top + 1

  game.lives = 2

  return game
end

function Game:update()
end
