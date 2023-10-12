AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

if Meteor.isClient
  require 'path-data-polyfill/path-data-polyfill.js'

class PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap.Path
  @minimumAntiAliasingAlpha = 10
  
  constructor: (@vectorTutorialBitmap, svgPath, offset) ->
    @canvas = new AM.ReadableCanvas @vectorTutorialBitmap.width(), @vectorTutorialBitmap.height()
    @canvas.context.translate offset.x, offset.y if offset

    # Rasterize the path to the canvas.
    path = new Path2D svgPath.getAttribute 'd'
    @canvas.context.stroke path
    
    @_imageData = @canvas.getFullImageData()
    
    for x in [0...@canvas.width]
      for y in [0...@canvas.height]
        pixelIndex = x + y * @_imageData.width
        alpha = @_imageData.data[pixelIndex * 4 + 3]
        @_imageData.data[pixelIndex * 4 + 3] = 0 if alpha < @constructor.minimumAntiAliasingAlpha
      
      @canvas.putFullImageData @_imageData
    
    # Calculate positions of corner points.
    @corners = []
    pathData = svgPath.getPathData normalize: true
    
    addCorner = (x, y) =>
      if offset
        x += offset.x
        y += offset.y
        
      @corners.push x: Math.floor(x), y: Math.floor(y)
    
    for segment in pathData
      switch segment.type
        when 'M', 'L'
          addCorner segment.values[0], segment.values[1]
          
        when 'C'
          addCorner segment.values[4], segment.values[5]
  
  _getPixelAlpha: (x, y) ->
    pixelIndex = x + y * @_imageData.width
    @_imageData.data[pixelIndex * 4 + 3]
    
  hasPixel: (x, y) ->
    @_getPixelAlpha(x, y) > 0
    
  completed: ->
    # For each of our pixels, make sure one exists in its vicinity.
    bitmapLayer = @vectorTutorialBitmap.bitmap()?.layers[0]
    
    pixelCoverage = new Uint8Array bitmapLayer.width * bitmapLayer.height * 2
    
    coveredPixelsCount = 0

    coverPixel = (x, y) =>
      pixelIndex = x + y * bitmapLayer.width
      pixelCoverage[pixelIndex * 2] = 1
      coveredPixelsCount++
      
    firstCoveredPixel = null
    
    for x in [0...bitmapLayer.width]
      for y in [0...bitmapLayer.height]
        if pixelAlpha = @_getPixelAlpha x, y
          found = false
          
          # Allow anti-aliased pixels to be covered from immediate neighbors.
          maxOffset = if pixelAlpha > 250 then 0 else 1
          
          for offset in [-maxOffset..maxOffset]
            found = true if @hasPixel(x + offset, y) and bitmapLayer.getPixel x + offset, y
            found = true if offset isnt 0 and @hasPixel(x, y + offset) and bitmapLayer.getPixel x, y + offset
            
          return false unless found
          
          if bitmapLayer.getPixel x, y
            coverPixel x, y
            firstCoveredPixel ?= {x, y}
          
    # Make sure all corners are covered.
    for corner in @corners
      return false unless bitmapLayer.getPixel corner.x, corner.y
      
    # Make sure all covered pixels are connected together.
    visitedPixelCount = 0
    
    visitPixel = (x, y) =>
      # Return if we've already visited this pixel.
      pixelIndex = x + y * bitmapLayer.width
      return if pixelCoverage[pixelIndex * 2 + 1] > 0

      # Return if this pixel wasn't covered.
      return if pixelCoverage[pixelIndex * 2] is 0
      
      # Mark that we've visited this pixel.
      pixelCoverage[pixelIndex * 2 + 1] = 1
      visitedPixelCount++
      
      # Visit all neighbors.
      for dx in [-1..1]
        for dy in [-1..1]
          continue if dx is 0 and dy is 0

          neighborX = x + dx
          neighborY = y + dy
          
          continue unless @hasPixel neighborX, neighborY

          visitPixel neighborX, neighborY
      
    visitPixel firstCoveredPixel.x, firstCoveredPixel.y
    
    visitedPixelCount is coveredPixelsCount
