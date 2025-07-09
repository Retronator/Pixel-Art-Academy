Game = {}
Game.__index = Game

function Game:new()
  local game = setmetatable({}, Game)

  game.design = {
    defender = {
      movement = DesignOptions.Defender.Movement.Horizontal,
      speed = 50
    },
    defenderProjectiles = {
      movement = DesignOptions.DefenderProjectiles.Movement.Up,
      speed = 150,
      maxCount = 10
    },
    invaders = {
      formation = {
        rows = 3,
        columns = 5,
        horizontalSpacing = 2,
        verticalSpacing = 2,
        movement = DesignOptions.Invaders.Formation.Movement.IndividualByRow,
        postponeMovement = DesignOptions.Invaders.Formation.PostponeMovement.UntilSpawnedAll,
        movementDelay = 0.01,
        horizontalMovementDistance = 2,
        verticalMovementDistance = 2,
        spawnDelay = 0.01
      },
      attackDirection = DesignOptions.Invaders.AttackDirection.Down,
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
