AB = Artificial.Base
AM = Artificial.Mirage
AS = Artificial.Spectrum
PADB = PixelArtDatabase

import * as StackBlur from 'stackblur-canvas'

PADB.Components.Stream.Artwork::_renderBackground = (displayedArtwork, image, displayScale) ->
  # Determine how many pixels the canvas should have.
  pixelWidth = Math.ceil @$artworkArea.outerWidth() / displayScale
  pixelHeight = Math.ceil @$artworkArea.outerHeight() / displayScale

  # Resize the canvas.
  @backgroundCanvas.width = pixelWidth
  @backgroundCanvas.height = pixelHeight
  @$backgroundCanvas.css
    width: pixelWidth * displayScale
    height: pixelHeight * displayScale

  # Determine which part of the source image to draw onto the background.
  drawTop = 0
  drawLeft = 0
  drawWidth = @backgroundCanvas.width
  drawHeight = @backgroundCanvas.height

  aspectRatio = image.width / image.height
  drawHeight = drawWidth / aspectRatio

  if drawHeight < @backgroundCanvas.height
    drawHeight = @backgroundCanvas.height
    drawWidth = drawHeight * aspectRatio

  drawTop = (@backgroundCanvas.height - drawHeight) / 2
  drawLeft = (@backgroundCanvas.width - drawWidth) / 2

  # Add a spotlight effect to the background for transparent images.
  gradient = @backgroundContext.createRadialGradient(pixelWidth / 2, pixelHeight / 2, 0, pixelWidth / 2, pixelHeight / 2, pixelWidth / 2)
  gradient.addColorStop 0, 'white'
  gradient.addColorStop 1, 'black'
  @backgroundContext.fillStyle = gradient
  @backgroundContext.fillRect 0, 0, pixelWidth, pixelHeight
  
  # Draw the image and blur it.
  @backgroundContext.drawImage image, drawLeft, drawTop, drawWidth, drawHeight
  StackBlur.canvasRGB @backgroundCanvas, 0, 0, pixelWidth, pixelHeight, 150

  # Reduce number of colors and apply dither.
  quantizationFactor = 48
  ditherSize = 4
  ditherThresholdMap = AS.PixelArt.getDitherThresholdMap ditherSize

  imageData = @backgroundContext.getImageData 0, 0, pixelWidth, pixelHeight

  for y in [0...pixelHeight]
    for x in [0...pixelWidth]
      pixelOffset = (y * pixelWidth + x) * 4

      ditherX = x % ditherSize
      ditherY = y % ditherSize
      ditherAmount = ditherThresholdMap[ditherY][ditherX]

      for channelOffset in [0..2]
        valueOffset = pixelOffset + channelOffset
        value = imageData.data[valueOffset]

        # Bring value to quantized range.
        value = value / 256 * quantizationFactor

        # Add dither.
        value += ditherAmount - 0.5

        # Quantize and scale back to byte range.
        value = Math.round(value) / quantizationFactor * 256

        # Blend the quantized value with the original.
        imageData.data[valueOffset] = value

  @backgroundContext.putImageData imageData, 0, 0
