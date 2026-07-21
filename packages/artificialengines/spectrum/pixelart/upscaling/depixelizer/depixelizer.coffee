AM = Artificial.Mirage
AS = Artificial.Spectrum
AP = Artificial.Pyramid

class AS.PixelArt.Upscaling.Depixelizer
  @RenderModes:
    Default: 'default'
    Splines: 'splines'
  
  @scale: (source, scale, options = {}) ->
    sourceImageData = AS.ImageDataHelpers.getImageData source
    
    scaledResult = @_scaleImage sourceImageData,
      height: sourceImageData.height * scale
      threshold: options.colorSimilarityThreshold
      borderPx: options.borderWidth
      renderMode: options.renderMode
    
    targetCanvas = new AM.ReadableCanvas scaledResult.width, scaledResult.height
    targetImageData = targetCanvas.getFullImageData()
    targetImageData.data.set scaledResult.data
    targetCanvas.putFullImageData targetImageData
    
    # Return the upscaled version.
    targetCanvas

  @getBSplines: (source, options = {}) ->
    sourceImageData = AS.ImageDataHelpers.getImageData source
    
    scaledResult = @_scaleImage sourceImageData,
      height: sourceImageData.height
      threshold: options.colorSimilarityThreshold
      borderPx: options.borderWidth
      renderMode: AS.PixelArt.Upscaling.Depixelizer.RenderModes.Splines

    getSplineKey = (spline) ->
      (point.join() for point in spline).join '|'

    getCanonicalSplineKey = (spline) ->
      forwardKey = getSplineKey spline
      reverseKey = getSplineKey spline.slice().reverse()
      if forwardKey < reverseKey then forwardKey else reverseKey

    # The JS extractor can report the same curve segment from both adjacent cells,
    # so expose each geometric spline only once regardless of direction.
    uniqueSplineKeys = new Set
    
    uniqueSplines = for spline in scaledResult.splines when spline?.length
      splineKey = getCanonicalSplineKey spline
      continue if uniqueSplineKeys.has splineKey
      
      uniqueSplineKeys.add splineKey
      spline

    for spline in uniqueSplines
      new AP.BSpline (new THREE.Vector2 point[0], point[1] for point in spline), AP.BSpline.Degrees.Quadratic
