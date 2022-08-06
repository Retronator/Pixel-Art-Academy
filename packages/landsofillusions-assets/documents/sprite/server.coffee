AE = Artificial.Everywhere
LOI = LandsOfIllusions

{PNG} = require 'pngjs'

WebApp.connectHandlers.use LOI.Assets.Sprite.documentUrl(), (request, response, next) ->
  query = request.query
  
  sprite = LOI.Assets.Sprite.documents.findOne query.id
  throw new AE.ArgumentException "Sprite not found." unless sprite
  
  response.writeHead 200, 'Content-type': 'application/json'
  response.write JSON.stringify sprite
  response.end()

WebApp.connectHandlers.use LOI.Assets.Sprite.imageUrl(), (request, response, next) ->
  query = request.query
  
  sprite = LOI.Assets.Sprite.documents.findOne query.id
  throw new AE.ArgumentException "Sprite not found." unless sprite

  engineSprite = new LOI.Assets.Engine.Sprite
    spriteData: -> sprite

  unless spriteImageData = engineSprite.getImageData()
    # There are no pixels in the sprite yet, so just return an empty 1px image.
    spriteImageData = new AM.Canvas(1, 1).getFullImageData()

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
