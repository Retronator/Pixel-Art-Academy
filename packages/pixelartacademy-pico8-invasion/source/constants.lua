Directions = {
  Up = 1,
  Down = 2,
  Left = 3,
  Right = 4,
}

Orientations = {
  Horizontal = 1,
  Vertical = 2
}

HorizontalAlignment = {
  Left = 1,
  Center = 2,
  Right = 3
}

VerticalAlignment = {
  Top = 1,
  Middle = 2,
  Bottom = 3
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
        Individual = 1,
        All = 2
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
