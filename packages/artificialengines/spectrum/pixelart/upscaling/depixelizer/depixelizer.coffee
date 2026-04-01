AM = Artificial.Mirage
AS = Artificial.Spectrum
AP = Artificial.Pyramid

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

  @getBezierCurves: (image, options = {}) ->
    sourceCanvas = new AM.ReadableCanvas image
    sourceImageData = sourceCanvas.getFullImageData()
    
    scaledResult = @_scaleImage sourceImageData,
      height: sourceCanvas.height
      threshold: options.colorSimilarityThreshold
      borderPx: options.borderWidth
      renderMode: AS.PixelArt.Upscaling.Depixelizer.RenderModes.Splines

    for spline in scaledResult.allSplines
      new AP.BezierCurve (new THREE.Vector2 point[0], point[1] for point in spline)
