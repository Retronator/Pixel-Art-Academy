Directions = {
  Up = 1,
  Down = 2,
  Left = 3,
  Right = 4
}

Orientations = {
  Horizontal = 1,
  Vertical = 2
}

DesignOptions = {
  Defender = {
    Movement = {
      Horizontal = 1,
      Vertical = 2,
      AllDirections = 3,
    }
  },
  DefenderProjectiles = {
    Movement = Directions
  },
  Invaders = {
    Formation = {
      Movement = {
        IndividualByRow = 1,
        IndividualByColumn = 2,
        ByRow = 3,
        ByColumn = 4,
        All = 5
      },
      PostponeMovement = {
        None = 1,
        UntilSpawnedAll = 2
      }
    },
    AttackDirection = Directions,
    Entry = {
      Appear = 1,
      FlyIn = 2
    },
    Attack = {
      None = 1,
      FlyOut = 2
    }
  }
}

function _init()
  game = Game:new()
  scene = Scene:new()
  invaders = Invaders:new()

  lifeIndicators = {}

  for life = 1, game.lives do
    add(lifeIndicators, Defender:new(1 + Defender.sprite.relativeCenterX + (life - 1) * (Defender.sprite.bounds.width + 1), 125 - Defender.sprite.relativeCenterY))
  end
end
