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

HorizontalAlignments = {
  Left = 1,
  Center = 2,
  Right = 3
}

VerticalAlignments = {
  Top = 1,
  Middle = 2,
  Bottom = 3
}

Sides = {
  Top = 1,
  Bottom = 2,
  Left = 3,
  Right = 4
}

Entities = {
  Defender = 1,
  Invader = 2,
  DefenderProjectile = 3,
  InvaderProjectile = 4,
  Shield = 5
}

DeathTypes = {
  Disappear = 1,
  Explode = 2
}

DesignOptions = {
  PostponeGameplay = {
    None = 1,
    UntilSpawnedAll = 2
  },
  Defender = {
    Movements = {
      Horizontal = 1,
      Vertical = 2,
      AllDirections = 3,
    }
  },
  Invaders = {
    Formation = {
      SpawnOrder = {
        Sequential = 1,
        Random = 2
      },
      MovementTypes = {
        Individual = 1,
        All = 2
      }
    }
  }
}
