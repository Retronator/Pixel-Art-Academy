AE = Artificial.Everywhere
AS = Artificial.Spectrum

class AS.Hqx
  @Modes:
    Default: 'Default'
    NoBlending: 'NoBlending'
    AlphaOnly: 'AlphaOnly'

  @scale: (image, scale, mode, antialiasing) ->
    switch mode
      when @Modes.NoBlending
        @_hqx image, scale, antialiasing, 0, 0, 0
      
      when @Modes.AlphaOnly
        @_scaleAlphaOnly image, scale, antialiasing

      else
        @_hqx image, scale, antialiasing

  @_scaleAlphaOnly: (image, scale, antialiasing) ->
    sourceCanvas = $('<canvas>')[0]
    sourceCanvas.width = image.width
    sourceCanvas.height = image.height

    # Draw the source image so we can read colors from it.
    sourceContext = sourceCanvas.getContext '2d'
    sourceContext.drawImage image, 0, 0
    sourceImageData = sourceContext.getImageData 0, 0, sourceCanvas.width, sourceCanvas.height

    # Expand colors by 1 pixel for lookups on the border. We don't want
    # to replace in place since that would bleed expanded pixels themselves.
    expandedImageData = sourceContext.getImageData 0, 0, sourceCanvas.width, sourceCanvas.height

    for x in [0...sourceCanvas.width]
      for y in [0...sourceCanvas.height]
        sourcePixelIndex = x + y * sourceCanvas.width

        # Skip already filled pixels.
        continue if sourceImageData.data[sourcePixelIndex * 4 + 3]

        neighbors = []
        for neighbor in [[-1, 0], [1, 0], [0, -1], [0, 1], [-1, -1], [-1, 1], [1, -1], [1, 1]]
          continue unless 0 < x + neighbor[0] < sourceCanvas.width - 1
          continue unless 0 < y + neighbor[1] < sourceCanvas.height - 1

          neighbors.push (x + neighbor[0]) + (y + neighbor[1]) * sourceCanvas.width

        for neighbor in neighbors
          if sourceImageData.data[neighbor * 4 + 3]
            for offset in [0..3]
              expandedImageData.data[sourcePixelIndex * 4 + offset] = sourceImageData.data[neighbor * 4 + offset]

            break

    # Get hxq upscaled version to get correct alpha.
    targetCanvas = @_hqx image, scale, antialiasing
    targetContext = targetCanvas.getContext '2d'
    targetImageData = targetContext.getImageData 0, 0, targetCanvas.width, targetCanvas.height

    # Copy color information from source to upscaled canvas.
    for x in [0...targetCanvas.width]
      for y in [0...targetCanvas.height]
        targetPixelIndex = x + y * targetCanvas.width
        sourcePixelIndex = Math.floor(x / scale) + Math.floor(y / scale) * sourceCanvas.width

        for offset in [0..2]
          targetImageData.data[targetPixelIndex * 4 + offset] = expandedImageData.data[sourcePixelIndex * 4 + offset]

    # Return the upscaled version.
    targetContext.putImageData targetImageData, 0, 0
    targetCanvas
