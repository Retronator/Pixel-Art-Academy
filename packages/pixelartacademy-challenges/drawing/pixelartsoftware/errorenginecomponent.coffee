PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.ErrorEngineComponent extends PAA.Practice.Challenges.Drawing.TutorialBitmap.EngineComponent
  constructor: (@options) ->
    super arguments...

    @ready = new ComputedField =>
      return unless @options.userBitmapData()
      return unless bitmapData = @options.bitmapData()
      return unless bitmapData.layers?.length and bitmapData.bounds
      return if bitmapData.palette and not LOI.Assets.Palette.documents.findOne bitmapData.palette._id

      true

    @drawMissingPixelsUpTo = new ReactiveField x: -1, y: -1

  _render: (context) ->
    userBitmapData = @options.userBitmapData()
    userPixels = userBitmapData.layers?[0]?.pixels

    bitmapData = @options.bitmapData()
    bitmapData.requirePixelMaps()
    palette = LOI.Assets.Palette.documents.findOne bitmapData.palette._id if bitmapData.palette

    # Draw background dots to empty pixels.
    for x in [0...bitmapData.bounds.width]
      for y in [0...bitmapData.bounds.height]
        @_drawHint context, x, y, @options.backgroundColor unless bitmapData.findPixelAtAbsoluteCoordinates x, y

    drawMissingPixelsUpTo = @drawMissingPixelsUpTo()
    drawMissingPixelsUpToIndex = drawMissingPixelsUpTo.x + drawMissingPixelsUpTo.y * bitmapData.bounds.width

    for layer in bitmapData.layers
      continue unless layer.pixels

      for pixel in layer.pixels
        # Skip the pixels that the user hasn't painted yet, unless we should draw them.
        pixelIndex = pixel.x + pixel.y * bitmapData.bounds.width

        if pixelIndex > drawMissingPixelsUpToIndex
          continue unless _.find userPixels, (userPixel) => userPixel.x is pixel.x and userPixel.y is pixel.y

        if pixel.paletteColor
          shades = palette.ramps[pixel.paletteColor.ramp].shades
          shadeIndex = THREE.Math.clamp pixel.paletteColor.shade, 0, shades.length - 1
          color = shades[shadeIndex]

        else if pixel.directColor
          color = pixel.directColor

        @_drawHint context, pixel.x, pixel.y, color
