function _draw()
  cls()
  scene:draw()

  rect(game.design.playfieldBounds.left - 1, game.design.playfieldBounds.top - 1, game.design.playfieldBounds.right + 1, game.design.playfieldBounds.bottom + 1, 6)

  print("score: " .. 0, 1, 1, 6)

  for lifeIndicator in all(lifeIndicators) do
    lifeIndicator:draw()
  end

  console.draw()
end
