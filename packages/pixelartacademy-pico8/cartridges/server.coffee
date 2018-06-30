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
  replaceSpriteSheetColor = (x, y, colorIndex) ->
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

  drawSprite = (spriteId, originX, originY, backgroundIndex, drawFunction) ->
    sprite = LOI.Assets.Sprite.documents.findOne spriteId

    # Recolor whole sprite bounds with background index.
    for x in [sprite.bounds.left..sprite.bounds.right]
      for y in [sprite.bounds.top..sprite.bounds.bottom]
        drawFunction originX + x, originY + y, backgroundIndex

    # Place individual sprite pixels.
    for pixel in sprite.layers[0].pixels
      drawFunction originX + pixel.x, originY + pixel.y, pixel.paletteColor.ramp

  replaceSprite = (spriteId, spriteSheetX, spriteSheetY, backgroundIndex) ->
    drawSprite spriteId, spriteSheetX, spriteSheetY, backgroundIndex, replaceSpriteSheetColor

  # Replace all assets.
  for asset in game.assets
    projectAsset = _.find project.assets, (projectAsset) -> projectAsset.id is asset.id

    assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
    backgroundIndex = assetClass.backgroundColor().paletteColor.ramp

    replaceSprite projectAsset.sprite._id, asset.x * 8, asset.y * 8, backgroundIndex

  # Prepare helpers to draw the label.
  pico8Palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.pico8

  replaceLabelColor = (x, y, colorIndex) ->
    # Only draw inside the label.
    return unless 0 <= x < 128 and 0 <= y < 128

    # Get RGB values for the colorIndex.
    color = pico8Palette.ramps[colorIndex].shades[0]

    # Offset the coordinates to cartridge label which starts at (16, 24).
    x += 16
    y += 24

    pngByteIndex = (x + y * png.width) * 4

    # Replace the higher six bits in each png pixel channel.
    png.data[pngByteIndex] = (png.data[pngByteIndex] & 3) | Math.floor(color.r * 255) & 252
    png.data[pngByteIndex + 1] = (png.data[pngByteIndex + 1] & 3) | Math.floor(color.g * 255) & 252
    png.data[pngByteIndex + 2] = (png.data[pngByteIndex + 2] & 3) | Math.floor(color.b * 255) & 252

  drawSpriteToLabel = (spriteId, labelX, labelY, backgroundIndex) ->
    drawSprite spriteId, labelX, labelY, backgroundIndex, replaceLabelColor

  if game.labelImage.assets
    for asset in game.labelImage.assets
      projectAsset = _.find project.assets, (projectAsset) -> projectAsset.id is asset.id

      assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
      backgroundIndex = assetClass.backgroundColor().paletteColor.ramp

      drawSpriteToLabel projectAsset.sprite._id, asset.x, asset.y, backgroundIndex

  buffer = PNG.sync.write png

  response.writeHead 200, 'Content-Type': 'image/png'
  response.end buffer
