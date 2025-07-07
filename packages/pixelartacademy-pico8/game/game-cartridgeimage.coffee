AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PNG = require 'fast-png'

class PAA.Pico8.Game extends PAA.Pico8.Game
  @Meta
    name: @id()
    replaceParent: true

  @enableDatabaseContent()

  getCartridgeImageUrlForProject: (projectId) ->
    # Load cartridge image.
    fetch(Meteor.absoluteUrl @cartridge.url).then((response) => response.arrayBuffer()).then (pngData) =>
      png = PNG.decode pngData

      new Promise (resolve, reject) =>
        Tracker.autorun (computation) =>
          LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.Pico8
          return unless pico8Palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.Pico8
          return unless project = PAA.Practice.Project.documents.findOne projectId
          computation.stop()

          @replaceCartridgeImageAssets png, project, pico8Palette
          replacedPng = PNG.encode png

          blob = new Blob [replacedPng], {'type': 'image/png'}
          resolve URL.createObjectURL blob

  replaceCartridgeImageAssets: (cartridgeImageData, project, pico8Palette) ->
    # Prepare helper methods.
    replaceSpriteSheetColor = (x, y, colorIndex) =>
      # Split the 4-bit color index into low and high 2 bits.
      low = colorIndex & 3
      high = (colorIndex & 12) >> 2

      spritePixelIndex = x + y * 128
      dataByteIndex = spritePixelIndex * 2

      if x % 2
        # Right pixel is written into alpha and red channels. Note that byte index is already pushed +2 ahead.
        lowOffset = -2
        highOffset = 1

      else
        # Left pixel is written into green and blue channels.
        lowOffset = 2
        highOffset = 1

      # Replace the lower two bits in each png pixel channel.
      cartridgeImageData.data[dataByteIndex + lowOffset] = (cartridgeImageData.data[dataByteIndex + lowOffset] & 252) | low
      cartridgeImageData.data[dataByteIndex + highOffset] = (cartridgeImageData.data[dataByteIndex + highOffset] & 252) | high

    drawBitmap = (bitmapId, originX, originY, backgroundIndex, drawFunction) =>
      if Meteor.isClient
        bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId

      else
        bitmap = LOI.Assets.Bitmap.documents.findOne bitmapId
        bitmap.initialize()

      for x in [bitmap.bounds.left..bitmap.bounds.right]
        for y in [bitmap.bounds.top..bitmap.bounds.bottom]
          if pixel = bitmap.findPixelAtAbsoluteCoordinates x, y
            colorIndex = pixel.paletteColor.ramp

          else
            colorIndex = backgroundIndex

          drawFunction originX + x, originY + y, colorIndex

    replaceSprite = (bitmapId, spriteSheetX, spriteSheetY, backgroundIndex) =>
      drawBitmap bitmapId, spriteSheetX, spriteSheetY, backgroundIndex, replaceSpriteSheetColor

    # Replace all assets.
    for asset in @assets
      projectAsset = _.find project.assets, (projectAsset) => projectAsset.id is asset.id
      throw new AE.InvalidOperationException "Project asset not found." unless projectAsset

      assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
      backgroundIndex = assetClass.backgroundColor().paletteColor.ramp

      replaceSprite projectAsset.bitmapId, asset.x * 8, asset.y * 8, backgroundIndex
      
    # Remove the hash to avoid detecting a corrupted cart.
    for hashAddress in [0x8006..0x8019]
      dataByteIndex = hashAddress * 4
      for offset in [0..3]
        cartridgeImageData.data[dataByteIndex + offset] = cartridgeImageData.data[dataByteIndex + offset] & 252
        cartridgeImageData.data[dataByteIndex + offset] = cartridgeImageData.data[dataByteIndex + offset] & 252

    # Prepare helpers to draw the label.
    replaceLabelColor = (x, y, colorIndex) =>
      # Only draw inside the label.
      return unless 0 <= x < 128 and 0 <= y < 128

      # Get RGB values for the colorIndex.
      color = pico8Palette.ramps[colorIndex].shades[0]

      # Offset the coordinates to cartridge label which starts at (16, 24).
      x += 16
      y += 24

      dataByteIndex = (x + y * cartridgeImageData.width) * 4

      # Replace the higher six bits in each png pixel channel.
      cartridgeImageData.data[dataByteIndex] = (cartridgeImageData.data[dataByteIndex] & 3) | Math.floor(color.r * 255) & 252
      cartridgeImageData.data[dataByteIndex + 1] = (cartridgeImageData.data[dataByteIndex + 1] & 3) | Math.floor(color.g * 255) & 252
      cartridgeImageData.data[dataByteIndex + 2] = (cartridgeImageData.data[dataByteIndex + 2] & 3) | Math.floor(color.b * 255) & 252

    drawSpriteToLabel = (bitmapId, labelX, labelY, backgroundIndex) =>
      drawBitmap bitmapId, labelX, labelY, backgroundIndex, replaceLabelColor

    if @labelImage.assets
      for asset in @labelImage.assets
        projectAsset = _.find project.assets, (projectAsset) => projectAsset.id is asset.id
        throw new AE.InvalidOperationException "Project asset not found." unless projectAsset

        assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
        backgroundIndex = assetClass.backgroundColor().paletteColor.ramp

        drawSpriteToLabel projectAsset.bitmapId, asset.x, asset.y, backgroundIndex
