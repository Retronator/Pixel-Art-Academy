PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap.HintsEngineComponent
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless @options.paths()
      
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
    paths = @options.paths()
    
    width = paths[0].canvas.width
    height = paths[0].canvas.height
    
    # Erase dots at empty pixels.
    for x in [0...width]
      for y in [0...height]
        found = false
        for path in paths
          if path.hasPixel x, y
            found = true
            break
            
        continue if found

        context.clearRect x + @_offset, y + @_offset, @_hintSize, @_hintSize
