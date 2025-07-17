function _init()
  Game.info = parseTable(stat(6))

  Game.design = {
    lives = 3,
    postponeGameplay = DesignOptions.PostponeGameplay.UntilSpawnedAll,
    defender = {
      movement = DesignOptions.Defender.Movement.Horizontal,
      horizontalAlignment = HorizontalAlignment.Center,
      verticalAlignment = VerticalAlignment.Bottom,
      speed = 1
    },
    defenderProjectiles = {
      movement = Directions.Up,
      speed = 2,
      maxCount = 1
    },
    invaders = {
      formation = {
        rows = 3,
        columns = 7,
        horizontalSpacing = 2,
        verticalSpacing = 2,
        horizontalAlignment = HorizontalAlignment.Center,
        verticalAlignment = VerticalAlignment.Top,
        movement = DesignOptions.Invaders.Formation.Movement.Individual,
        horizontalSpeed = 2,
        verticalSpeed = 8,
        spawnDelay = 0.01,
        shooting = {
          timeoutFull = 3,
          timeoutFullDecreasePerLevel = 0.5,
          timeoutEmpty = 1,
          variability = 0.25
        }
      },
      attackDirection = DesignOptions.Invaders.AttackDirection.Down,
      scorePerInvader = 10
    },
    invaderProjectiles = {
      movement = Directions.Down,
      speed = 1,
      maxCount = 3
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

  Game.design.playfieldBounds.width = Game.design.playfieldBounds.right - Game.design.playfieldBounds.left + 1
  Game.design.playfieldBounds.height = Game.design.playfieldBounds.bottom - Game.design.playfieldBounds.top + 1

  game = nil
  scene = nil
  invaders = nil

  sfx(10)

  -- Report the cartridge was run.
  poke(0x5f81, 1)
end
