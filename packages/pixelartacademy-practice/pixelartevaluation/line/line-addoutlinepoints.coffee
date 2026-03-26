AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Line::addOutlinePoints = (core, startingPoint) ->
  @assignPoint startingPoint
  startingPoint.assignLine @

  previousPoint = startingPoint
  currentPoint = _.find startingPoint.neighbors, (point) => point.pixels.length is 1 and core in point.pixels[0].outlineCores

  @assignPoint currentPoint
  currentPoint.assignLine @
  
  @isClosed = true
  
  getEmptySpots = (point) =>
    emptySpots = []
    emptySpots.push {x: point.x - 1, y: point.y} unless @layer.getPixel point.x - 1, point.y
    emptySpots.push {x: point.x + 1, y: point.y} unless @layer.getPixel point.x + 1, point.y
    emptySpots.push {x: point.x, y: point.y - 1} unless @layer.getPixel point.x, point.y - 1
    emptySpots.push {x: point.x, y: point.y + 1} unless @layer.getPixel point.x, point.y + 1
    emptySpots
  
  loop
    # Complete the line when we've reached the starting point again.
    break if startingPoint isnt previousPoint and startingPoint in currentPoint.neighbors

    neighborsOnOutline = _.filter currentPoint.neighbors, (point) =>
      # Only include points on the same outline.
      return unless outlinePixel = point.getOutlinePixel()
      core in outlinePixel.outlineCores

    if neighborsOnOutline.length > 2
      # There are multiple neighbors, so we must be on an inside outline. We should
      # attempt to close the outline around the previous nearby empty spot.
      emptySpots = getEmptySpots previousPoint
      
      _.remove neighborsOnOutline, (point) =>
        # For this point to be eligible, it needs to share an empty spot with the current point.
        for neighborEmptySpot in getEmptySpots point
          return false if _.find emptySpots, (emptySpot) -> emptySpot.x is neighborEmptySpot.x and emptySpot.y is neighborEmptySpot.y

        true
      
      if neighborsOnOutline.length > 2
        console.error "Couldn't find a single point that would continue the inner outline around the nearest empty spots."
        @isClosed = false
        break
      
    nextPoint = _.find neighborsOnOutline, (point) => point isnt previousPoint
    
    unless nextPoint
      console.error "Could not find the next point and close the outline.", currentPoint, @
      @isClosed = false
      break
    
    @assignPoint nextPoint unless nextPoint in @points
    nextPoint.assignLine @
    
    previousPoint = currentPoint
    currentPoint = nextPoint
    
  for point in @points
    for pixel in point.pixels
      @addPixel pixel unless pixel in @pixels
