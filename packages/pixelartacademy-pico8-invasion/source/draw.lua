function _draw()
  cls()
  scene:draw()

  rect(gameDesign.playfieldBounds.left - 1, gameDesign.playfieldBounds.top - 1, gameDesign.playfieldBounds.right + 1, gameDesign.playfieldBounds.bottom + 1, 6)

  print("score: " .. 0, 1, 1, 6)

  for lifeIndicator in all(lifeIndicators) do
    lifeIndicator:draw()
  end
end
