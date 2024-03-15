AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum

class AS.Hqx
  @Modes:
    Default: 'Default'
    NoBlending: 'NoBlending'

  @scale: (image, scale, mode, antialiasing, separateAlpha) ->
    if separateAlpha
      @_scaleAlphaSeparately image, scale, mode, antialiasing
      
    else
      @_scale image, scale, mode, antialiasing
      
  @_scale: (image, scale, mode, antialiasing) ->
    switch mode
      when @Modes.NoBlending
        @_hqx image, scale, antialiasing, 0, 0, 0

      else
        @_hqx image, scale, antialiasing
        
  @_scaleAlphaSeparately: (image, scale, mode, antialiasing) ->
    # Expand colors by 1 pixel for lookups on the alpha borders.
    colorSourceCanvas = new AM.ReadableCanvas image
    colorSourceImageData = colorSourceCanvas.getFullImageData()
    AS.ImageDataHelpers.expandPixels colorSourceImageData, 1
    colorSourceCanvas.putFullImageData colorSourceImageData
    
    # Get upscaled color channels.
    colorSourceCanvas = @_scale colorSourceCanvas, scale, mode, antialiasing
    colorSourceImageData = colorSourceCanvas.getFullImageData()

    # Recolor the alpha image to white so hqx treats it as uniform.
    alphaSourceCanvas = new AM.ReadableCanvas image
    alphaSourceImageData = alphaSourceCanvas.getFullImageData()

    for x in [0...alphaSourceCanvas.width]
      for y in [0...alphaSourceCanvas.height]
        sourcePixelIndex = x + y * alphaSourceCanvas.width

        for offset in [0..2]
          alphaSourceImageData.data[sourcePixelIndex * 4 + offset] = 255
    
    alphaSourceCanvas.putFullImageData alphaSourceImageData
    
    # Get upscaled image with correct alpha channel.
    targetCanvas = @_scale alphaSourceCanvas, scale, antialiasing
    targetImageData = targetCanvas.getFullImageData()

    # Copy color information from source to upscaled canvas.
    for x in [0...targetCanvas.width]
      for y in [0...targetCanvas.height]
        targetPixelIndex = x + y * targetCanvas.width

        for offset in [0..2]
          dataIndex = targetPixelIndex * 4 + offset
          targetImageData.data[dataIndex] = colorSourceImageData.data[dataIndex]
    
    targetCanvas.putFullImageData targetImageData

    # Return the upscaled version.
    targetCanvas
