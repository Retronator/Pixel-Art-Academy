function _draw()
  cls()

  rect(Game.design.playfieldBounds.left - 1, Game.design.playfieldBounds.top - 1, Game.design.playfieldBounds.right + 1, Game.design.playfieldBounds.bottom + 1, 6)
  print("score: " .. (game ~= nil and game.score or 0), 1, 1, 6)

  levelText = "level: " .. (game ~= nil and game.level or 1)
  print(levelText, 128 - #levelText * 4, 1, 6)

  if game == nil then
    print("invasion", 48, 40, 7)
    print("press button to start", 22, 60, 7)
    spr(0,56,76, 2, 2)
    spr(2,16,24, 2, 2)
    spr(2,100,36, 2, 2)

  else
    scene:draw()

    if Game.design.hasDefender then
      for life = 1, game.lives - 1 do
        lifeX = 1 + Defender.sprite.relativeCenterX + (life - 1) * (Defender.sprite.bounds.width + 1)
        lifeY = 125 - Defender.sprite.relativeCenterY
        Defender.sprite:draw(lifeX, lifeY)
      end
    end

    if game.lives == 0 then
      print("press button to start",22,55, 7)
    end
  end

  console.draw()
end
