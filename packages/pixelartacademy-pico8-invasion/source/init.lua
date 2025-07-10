function _init()
  game = Game:new()
  scene = Scene:new()
  invaders = Invaders:new()

  lifeIndicators = {}

  for life = 1, game.lives do
    add(lifeIndicators, Defender:new(1 + Defender.sprite.relativeCenterX + (life - 1) * (Defender.sprite.bounds.width + 1), 125 - Defender.sprite.relativeCenterY))
  end
end
