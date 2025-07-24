function _init()
  Game.design = parseTable(stat(6))

  -- Apply defaults if we didn't get the design from the starting parameter.
  if not next(Game.design) then
    Game.design = {
      lives = 3,
      entities = {
        Entities.Defender,
        Entities.Invader,
        Entities.DefenderProjectile,
        Entities.InvaderProjectile,
        Entities.Shield
      },
      postponeGameplay = DesignOptions.PostponeGameplay.UntilSpawnedAll,
      defender = {
        movement = DesignOptions.Defender.Movements.Horizontal,
        startingAlignment = {
          horizontal = HorizontalAlignments.Left,
          vertical = VerticalAlignments.Bottom,
        },
        speed = 1
      },
      defenderProjectiles = {
        direction = Directions.Up,
        speed = 2,
        maxCount = 1
      },
      invaders = {
        formation = {
          rows = 3,
          columns = 7,
          horizontalSpacing = 2,
          verticalSpacing = 2,
          startingAlignment = {
            horizontal = HorizontalAlignments.Center,
            vertical = VerticalAlignments.Top,
          },
          movementOrientation = Orientations.Horizontal,
          movementType = DesignOptions.Invaders.Formation.MovementTypes.Individual,
          attackDirection = Directions.Down,
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
        scorePerInvader = 10,
        scoreIncreasePerInvaderPerLevel = 0
      },
      invaderProjectiles = {
        direction = Directions.Down,
        speed = 1,
        maxCount = 3
      },
      shields = {
        amount = 4,
        spacing = 16,
        side = Sides.Bottom
      }
    }
  end

  Game.design.playfieldBounds = {
    left = 0,
    right = 127,
    top = 8,
    bottom = 124 - Defender.sprite.bounds.height
  }

  Game.design.playfieldBounds.width = Game.design.playfieldBounds.right - Game.design.playfieldBounds.left + 1
  Game.design.playfieldBounds.height = Game.design.playfieldBounds.bottom - Game.design.playfieldBounds.top + 1

  for entity, value in pairs(Entities) do
    Game.design['has'..entity] = Game:designHasEntity(value)
  end

  game = nil
  scene = nil
  invaders = nil

  sfx(10)

  -- Report the cartridge was run.
  poke(0x5f81, 1)
end
