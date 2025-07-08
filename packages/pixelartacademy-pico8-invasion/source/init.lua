DesignOptions = {
  DefenderMovement = {
    Horizontal = 1,
    Vertical = 2,
    AllDirections = 3,
  },
  DefenderProjectileMovement = {
    Up = 1,
    Down = 2,
    Left = 3,
    Right = 4
  }
}

function _init()
  local defender = Defender:new(0,0)

  gameDesign = {
    defenderMovement = DesignOptions.DefenderMovement.AllDirections,
    defenderSpeed = 50,
    defenderProjectileMovement = DesignOptions.DefenderProjectileMovement.Up,
    defenderProjectileSpeed = 150,
    defenderProjectilesMaxCount = 1,
    playfieldBounds = {
      left = 0,
      right = 127,
      top = 8,
      bottom = 124 - defender.sprite.bounds.height,
    }
  }

  gameDesign.playfieldBounds.width = gameDesign.playfieldBounds.right - gameDesign.playfieldBounds.left + 1
  gameDesign.playfieldBounds.height = gameDesign.playfieldBounds.bottom - gameDesign.playfieldBounds.top + 1

  scene = Scene:new()

  lives = 2
  lifeIndicators = {}

  for life = 1,lives do
    add(lifeIndicators, Defender:new(1 + defender.sprite.relativeCenterX + (life - 1) * (defender.sprite.bounds.width + 1), 125 - defender.sprite.relativeCenterY))
  end
end
