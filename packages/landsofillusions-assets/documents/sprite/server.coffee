AE = Artificial.Everywhere
LOI = LandsOfIllusions

{PNG} = require 'pngjs'

WebApp.connectHandlers.use '/assets/sprite.png', (request, response, next) ->
  query = request.query
  
  sprite = LOI.Assets.Sprite.documents.findOne query.spriteId
  throw new AE.ArgumentException "Sprite not found." unless sprite

  engineSprite = new LOI.Assets.Engine.Sprite
    spriteData: -> sprite

  spriteImageData = engineSprite.getImageData()

  # Create the PNG.
  png = new PNG
    width: spriteImageData.width
    height: spriteImageData.height

  # Copy data from engine sprite to the PNG.
  png.data.set spriteImageData.data

  # Return the PNG.
  buffer = PNG.sync.write png

  response.writeHead 200, 'Content-Type': 'image/png'
  response.end buffer
