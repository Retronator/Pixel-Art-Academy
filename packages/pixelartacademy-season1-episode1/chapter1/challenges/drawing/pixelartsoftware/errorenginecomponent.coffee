PAA = PixelArtAcademy
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.PixelArtSoftware.CopyReference.ErrorEngineComponent
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless @options.userSpriteData()
      return unless spriteData = @options.spriteData()
      return unless spriteData.layers?.length and spriteData.bounds
      return if spriteData.palette and not LOI.Assets.Palette.documents.findOne spriteData.palette._id

      true

    # Hints are 5x smaller dots in the middle of a pixel.
    @pixelToHintRatio = 5
    @hintOffset = Math.floor @pixelToHintRatio / 2

    @drawMissingPixelsUpTo = new ReactiveField x: 0, y: 0

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()

    @_render renderOptions

    bounds = @options.spriteData().bounds

    context.imageSmoothingEnabled = false
    context.drawImage @_canvas, bounds.x, bounds.y, bounds.width, bounds.height

  _render: (renderOptions) ->
    userSpriteData = @options.userSpriteData()
    userPixels = userSpriteData.layers?[0]?.pixels

    spriteData = @options.spriteData()

    palette = LOI.Assets.Palette.documents.findOne spriteData.palette._id if spriteData.palette

    # Build a new canvas if needed.
    @_canvas ?= $('<canvas>')[0]

    # Resize the canvas if needed.
    @_canvas.width = spriteData.bounds.width * @pixelToHintRatio unless @_canvas.width is spriteData.bounds.width * @pixelToHintRatio
    @_canvas.height = spriteData.bounds.height * @pixelToHintRatio unless @_canvas.height is spriteData.bounds.height * @pixelToHintRatio

    @_context = @_canvas.getContext '2d'
    @_imageData = @_context.getImageData 0, 0, @_canvas.width, @_canvas.height
    @_canvasPixelsCount = @_canvas.width * @_canvas.height

    # Clear the image buffer to transparent.
    @_imageData.data.fill 0

    # Draw background dots to all pixels.
    for x in [0...spriteData.bounds.width]
      for y in [0...spriteData.bounds.height]
        @_paintPixel spriteData, x, y, @options.backgroundColor

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

        @_paintPixel spriteData, pixel.x, pixel.y, color

    @_context.putImageData @_imageData, 0, 0

  _paintPixel: (spriteData, pixelX, pixelY, color) =>
    spritePixelX = pixelX - spriteData.bounds.x
    spritePixelY = pixelY - spriteData.bounds.y

    x = spritePixelX * @pixelToHintRatio + @hintOffset
    y = spritePixelY * @pixelToHintRatio + @hintOffset

    pixelIndex = (x + y * @_canvas.width) * 4

    @_imageData.data[pixelIndex] = color.r * 255
    @_imageData.data[pixelIndex + 1] = color.g * 255
    @_imageData.data[pixelIndex + 2] = color.b * 255
    @_imageData.data[pixelIndex + 3] = 255
