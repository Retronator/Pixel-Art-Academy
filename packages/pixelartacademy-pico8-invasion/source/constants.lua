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

Sides = {
  Top = 1,
  Bottom = 2,
  Left = 3,
  Right = 4
}

DesignOptions = {
  PostponeGameplay = {
    None = 1,
    UntilSpawnedAll = 2
  },
  Defender = {
    Movement = {
      Horizontal = 1,
      Vertical = 2,
      AllDirections = 3,
    },
  },
  DefenderProjectiles = {
    Movement = Directions
  },
  Invaders = {
    Formation = {
      Movement = {
        Individual = 1,
        All = 2
      }
    },
    AttackDirection = Directions
  },
  InvaderProjectiles = {
    Movement = Directions
  },
}
