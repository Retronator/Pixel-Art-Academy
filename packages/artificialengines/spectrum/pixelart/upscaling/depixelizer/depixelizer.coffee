AM = Artificial.Mirage
AS = Artificial.Spectrum

class AS.PixelArt.Upscaling.Depixelizer
  @RenderModes:
    Default: 'default'
    Splines: 'splines'
  
  @scale: (image, scale, options = {}) ->
    sourceCanvas = new AM.ReadableCanvas image
    sourceImageData = sourceCanvas.getFullImageData()
    
    scaledResult = @_scaleImage sourceImageData,
      height: sourceCanvas.height * scale
      threshold: options.colorSimilarityThreshold
      borderPx: options.borderWidth
      renderMode: options.renderMode
    
    targetCanvas = new AM.ReadableCanvas scaledResult.width, scaledResult.height
    targetImageData = targetCanvas.getFullImageData()
    targetImageData.data.set scaledResult.data
    targetCanvas.putFullImageData targetImageData
    
    # Return the upscaled version.
    targetCanvas
