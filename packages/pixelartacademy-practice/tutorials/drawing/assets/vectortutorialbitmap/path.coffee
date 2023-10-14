AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

if Meteor.isClient
  require 'path-data-polyfill/path-data-polyfill.js'

class PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap.Path
  @minimumAntiAliasingAlpha = 10
  @minimumRequiredPixelAlpha = 250
  
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
        
        if alpha < @constructor.minimumAntiAliasingAlpha
          @_imageData.data[pixelIndex * 4 + 3] = 0
          
        else
          # Turn anti-aliased pixels blue and required green for debugging purposes.
          channelOffset = if alpha > @constructor.minimumRequiredPixelAlpha then 1 else 2
          @_imageData.data[pixelIndex * 4 + channelOffset] = 255
          
          # Make allowed pixels more visible, but don't change their
          # upper end since that's used for detecting required pixels.
          @_imageData.data[pixelIndex * 4 + 3] = Math.max 128, alpha
        
    # Calculate positions of corner points.
    @cornersOfParts = []
    pathData = svgPath.getPathData normalize: true
    
    currentCornersOfPart = null

    addCorner = (x, y) =>
      if offset
        x += offset.x
        y += offset.y
        
      x = Math.floor x
      y = Math.floor y
      
      currentCornersOfPart.push {x, y}

      # Turn corners red for debugging purposes.
      pixelIndex = x + y * @_imageData.width
      @_imageData.data[pixelIndex * 4] = 255
      @_imageData.data[pixelIndex * 4 + 1] = 0
      @_imageData.data[pixelIndex * 4 + 2] = 0
      
      # HACK: Electron's Chrome produces different rasterization results that
      # sometimes leave ends unpainted, so we force them to have alpha here.
      @_imageData.data[pixelIndex * 4 + 3] = 255
    
    for segment in pathData
      if segment.type is 'M'
        @cornersOfParts.push currentCornersOfPart if currentCornersOfPart
        currentCornersOfPart = []
      
      switch segment.type
        when 'M', 'L'
          addCorner segment.values[0], segment.values[1]
          
        when 'C'
          addCorner segment.values[4], segment.values[5]
    
    @cornersOfParts.push currentCornersOfPart
    
    @canvas.putFullImageData @_imageData
  
  _getPixelAlpha: (x, y) ->
    pixelIndex = x + y * @_imageData.width
    @_imageData.data[pixelIndex * 4 + 3]
    
  hasPixel: (x, y) ->
    @_getPixelAlpha x, y
    
  completed: ->
    # Make sure all corners are covered.
    bitmapLayer = @vectorTutorialBitmap.bitmap()?.layers[0]

    for cornersForPart in @cornersOfParts
      for corner in cornersForPart
        return false unless bitmapLayer.getPixel corner.x, corner.y
        
    # For each of our pixels, make sure one exists in its vicinity.
    pixelCoverage = new Uint8Array bitmapLayer.width * bitmapLayer.height * 2
    
    coveredPixelsCount = 0

    coverPixel = (x, y) =>
      pixelIndex = x + y * bitmapLayer.width
      pixelCoverage[pixelIndex * 2] = 1
      coveredPixelsCount++
      
    for x in [0...bitmapLayer.width]
      for y in [0...bitmapLayer.height]
        if pixelAlpha = @_getPixelAlpha x, y
          found = false
          
          # Allow anti-aliased pixels to be covered from immediate neighbors.
          maxOffset = if pixelAlpha > @constructor.minimumRequiredPixelAlpha then 0 else 1
          
          for dx in [-maxOffset..maxOffset]
            for dy in [-maxOffset..maxOffset]
              found = true if @hasPixel(x + dx, y + dy) and bitmapLayer.getPixel x + dx, y + dy
            
          return false unless found
          
          coverPixel x, y if bitmapLayer.getPixel x, y
      
    # Make sure all covered pixels of parts are connected together.
    visitPixel = (x, y) =>
      # Return if we've already visited this pixel.
      pixelIndex = x + y * bitmapLayer.width
      return if pixelCoverage[pixelIndex * 2 + 1] > 0

      # Return if this pixel wasn't covered.
      return if pixelCoverage[pixelIndex * 2] is 0
      
      # Mark that we've visited this pixel.
      pixelCoverage[pixelIndex * 2 + 1] = 1
      
      # Visit all neighbors.
      # Note: We need unique variables and not use dx, dy since those are
      # scoped to the outer method and not redeclared for each call of recursion.
      for neighborDx in [-1..1]
        for neighborDy in [-1..1]
          continue if neighborDx is 0 and neighborDy is 0

          neighborX = x + neighborDx
          neighborY = y + neighborDy
          
          continue unless @hasPixel neighborX, neighborY

          visitPixel neighborX, neighborY
      
      # Prevent collection of results from the loops.
      return
      
    pixelVisited = (x, y) =>
      pixelIndex = x + y * bitmapLayer.width
      pixelCoverage[pixelIndex * 2 + 1]
    
    for cornersForPart in @cornersOfParts
      # Visit pixels from the initial corner.
      visitPixel cornersForPart[0].x, cornersForPart[0].y
      
      for corner in cornersForPart
        return false unless pixelVisited corner.x, corner.y

    true
