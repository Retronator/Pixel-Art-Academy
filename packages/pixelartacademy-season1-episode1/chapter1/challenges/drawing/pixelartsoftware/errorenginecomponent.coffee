PAA = PixelArtAcademy
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.PixelArtSoftware.CopyReference.ErrorEngineComponent extends PAA.Practice.Challenges.Drawing.TutorialSprite.EngineComponent
  constructor: (@options) ->
    super arguments...

    @ready = new ComputedField =>
      return unless @options.userSpriteData()
      return unless spriteData = @options.spriteData()
      return unless spriteData.layers?.length and spriteData.bounds
      return if spriteData.palette and not LOI.Assets.Palette.documents.findOne spriteData.palette._id

      true

    @drawMissingPixelsUpTo = new ReactiveField x: -1, y: -1

  _render: (context) ->
    userSpriteData = @options.userSpriteData()
    userPixels = userSpriteData.layers?[0]?.pixels

    spriteData = @options.spriteData()
    spriteData.requirePixelMaps()
    palette = LOI.Assets.Palette.documents.findOne spriteData.palette._id if spriteData.palette

    # Draw background dots to empty pixels.
    for x in [0...spriteData.bounds.width]
      for y in [0...spriteData.bounds.height]
        @_drawHint context, x, y, @options.backgroundColor unless spriteData.findPixelAtAbsoluteCoordinates x, y

    drawMissingPixelsUpTo = @drawMissingPixelsUpTo()
    drawMissingPixelsUpToIndex = drawMissingPixelsUpTo.x + drawMissingPixelsUpTo.y * spriteData.bounds.width

    for layer in spriteData.layers
      continue unless layer.pixels

      for pixel in layer.pixels
        # Skip the pixels that the user hasn't painted yet, unless we should draw them.
        pixelIndex = pixel.x + pixel.y * spriteData.bounds.width

        if pixelIndex > drawMissingPixelsUpToIndex
          continue unless _.find userPixels, (userPixel) => userPixel.x is pixel.x and userPixel.y is pixel.y

        if pixel.paletteColor
          shades = palette.ramps[pixel.paletteColor.ramp].shades
          shadeIndex = THREE.Math.clamp pixel.paletteColor.shade, 0, shades.length - 1
          color = shades[shadeIndex]

        else if pixel.directColor
          color = pixel.directColor

        @_drawHint context, pixel.x, pixel.y, color
