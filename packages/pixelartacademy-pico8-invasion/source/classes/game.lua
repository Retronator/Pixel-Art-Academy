Game = {}
Game.__index = Game

function Game:new()
  local game = setmetatable({}, Game)

  game.design = {
    defender = {
      movement = DesignOptions.Defender.Movement.Horizontal,
      horizontalAlignment = HorizontalAlignment.Center,
      verticalAlignment = VerticalAlignment.Bottom,
      speed = 1
    },
    defenderProjectiles = {
      movement = Directions.Up,
      speed = 2,
      maxCount = 10
    },
    invaders = {
      formation = {
        rows = 3,
        columns = 3,
        horizontalSpacing = 2,
        verticalSpacing = 2,
        horizontalAlignment = HorizontalAlignment.Center,
        verticalAlignment = VerticalAlignment.Top,
        movement = DesignOptions.Invaders.Formation.Movement.Individual,
        postponeMovement = DesignOptions.Invaders.Formation.PostponeMovement.UntilSpawnedAll,
        horizontalSpeed = 0,
        verticalSpeed = 0,
        spawnDelay = 0.01
      },
      attackDirection = DesignOptions.Invaders.AttackDirection.Down,
      entry = DesignOptions.Invaders.Entry.Appear,
      attack = DesignOptions.Invaders.Attack.None,
    },
    shields = {
      amount = 4,
      spacing = 16,
      side = Sides.Bottom
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
