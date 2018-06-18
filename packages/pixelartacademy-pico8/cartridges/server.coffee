AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PNG = Npm.require('pngjs').PNG
Request = request

WebApp.connectHandlers.use '/pico8/cartridge.png', (request, response, next) ->
  query = request.query
  
  game = PAA.Pico8.Game.documents.findOne query.gameId
  throw new AE.ArgumentException "Game not found." unless game

  project = PAA.Practice.Project.documents.findOne query.projectId
  throw new AE.ArgumentException "Project not found." unless project

  cartridgeUrl = game.cartridge.url

  # Create a local URL if needed.
  cartridgeUrl = Meteor.absoluteUrl cartridgeUrl unless cartridgeUrl.indexOf('http') > -1

  # Get the cartridge url
  cartrigeResponse = Request.getSync cartridgeUrl, encoding: null
  png = PNG.sync.read cartrigeResponse.body

  # Prepare helper methods.
  replaceColorIndex = (x, y, colorIndex) ->
    # Split the 4-bit color index into low and high 2 bits.
    low = colorIndex & 3
    high = (colorIndex & 12) >> 2

    spritePixelIndex = x + y * 128
    pngByteIndex = spritePixelIndex * 2

    if x % 2
      # Right pixel is written into alpha and red channels. Note that byte index is already pushed +2 ahead.
      lowOffset = -2
      highOffset = 1

    else
      # Left pixel is written into green and blue channels.
      lowOffset = 2
      highOffset = 1

    # Replace the lower two bits in each png pixel channel.
    png.data[pngByteIndex + lowOffset] = (png.data[pngByteIndex + lowOffset] & 252) | low
    png.data[pngByteIndex + highOffset] = (png.data[pngByteIndex + highOffset] & 252) | high

  replaceSprite = (spriteId, originX, originY, backgroundIndex) ->
    sprite = LOI.Assets.Sprite.documents.findOne spriteId

    # Recolor whole sprite bounds with background index.
    for x in [sprite.bounds.left..sprite.bounds.right]
      for y in [sprite.bounds.top..sprite.bounds.bottom]
        replaceColorIndex originX + x, originY + y, backgroundIndex

    # Place individual sprite pixels.
    for pixel in sprite.layers[0].pixels
      replaceColorIndex originX + pixel.x, originY + pixel.y, pixel.paletteColor.ramp

  # Replace all assets.
  for asset in game.assets
    projectAsset = _.find project.assets, (projectAsset) -> projectAsset.id is asset.id

    assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
    backgroundIndex = assetClass.backgroundColor().paletteColor.ramp

    replaceSprite projectAsset.sprite._id, asset.x * 8, asset.y * 8, backgroundIndex

  buffer = PNG.sync.write png

  response.writeHead 200, 'Content-Type': 'image/png'
  response.end buffer
