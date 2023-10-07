PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.EngineComponent
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless spriteData = @options.spriteData()
      return unless spriteData.layers?.length and spriteData.bounds
      return unless spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette._id

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()

    @_prepareSize renderOptions
    @_render context

  _prepareSize: (renderOptions) ->
    # Hints are ideally 5x smaller dots in the middle of a pixel.
    pixelSize = renderOptions.camera.effectiveScale()
    hintSize = Math.ceil pixelSize / 5
    offset = Math.floor (pixelSize - hintSize) / 2

    # We need to store sizes relative to the pixel.
    @_hintSize = hintSize / pixelSize
    @_offset = offset / pixelSize

    # If pixel is less than 2 big, we should lower the opacity of the hint to mimic less coverage.
    @_opacity = if pixelSize < 2 then pixelSize / 5 else 1

  _render: (context) ->
    spriteData = @options.spriteData()
    spriteData.requirePixelMaps()
    palette = spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette._id

    # Draw background dots to empty pixels.
    if @options.backgroundColor
      for x in [0...spriteData.bounds.width]
        for y in [0...spriteData.bounds.height]
          @_drawHint context, x, y, @options.backgroundColor unless spriteData.findPixelAtAbsoluteCoordinates x, y

    for layer in spriteData.layers
      continue unless layer.pixels

      for pixel in layer.pixels
        if pixel.paletteColor
          shades = palette.ramps[pixel.paletteColor.ramp].shades
          shadeIndex = THREE.Math.clamp pixel.paletteColor.shade, 0, shades.length - 1
          color = shades[shadeIndex]

        else if pixel.directColor
          color = pixel.directColor

        @_drawHint context, pixel.x, pixel.y, color

  _drawHint: (context, pixelX, pixelY, color) ->
    context.fillStyle = "rgba(#{color.r * 255}, #{color.g * 255}, #{color.b * 255}, #{@_opacity})"
    context.fillRect pixelX + @_offset, pixelY + @_offset, @_hintSize, @_hintSize
