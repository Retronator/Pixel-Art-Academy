LOI = LandsOfIllusions
OrganicSolver = LOI.Assets.Mesh.Object.Solver.Organic

class OrganicSolver.Island.Part.Contour
  constructor: (@islandPart) ->
    # Note: Contour segments are directed so that the island part is on the right of the segment.
    @segments = []
    @segmentsMap = {}

  startRecomputation: ->
    # Note: Contour vertices are located in the top-left corner of the pixel at their vertex coordinates.
    @vertices = []
    @verticesMap = {}

    @changed = false

    # Mark all segments as not added.
    segment.added = false for segment in @segments

  endRecomputation: ->
    # See if all segments were re-added.
    for segment in @segments
      unless segment.added
        # A segment was not added, so it must have been removed and this contour has changed.
        @changed = true
        @segmentsMap[segment[0].x][segment[0].y][segment[1].x][segment[1].y] = null

    _.remove @segments, (segment) -> not segment.added

    return unless @segments.length

    # Connect all the segments
    segment.next = null for segment in @segments

    pointEquals = (a, b) => a.x is b.x and a.y is b.y

    currentSegment = @segments[0]

    loop
      # See if we're back at the beginning.
      if pointEquals currentSegment[1], @segments[0][0]
        currentSegment.next = @segments[0]
        break

      # Find the segment that continues the contour.
      for testSegmentIndex in [1...@segments.length]
        testSegment = @segments[testSegmentIndex]
        continue if testSegment.next

        if pointEquals currentSegment[1], testSegment[0]
          currentSegment.next = testSegment
          currentSegment = testSegment
          break

  addSegment: (coordinates, startXOffset, startYOffset, endXOffset, endYOffset) ->
    start =
      x: coordinates.x + startXOffset
      y: coordinates.y + startYOffset

    end =
      x: coordinates.x + endXOffset
      y: coordinates.y + endYOffset

    if existingSegment = @segmentsMap[start.x]?[start.y]?[end.x]?[end.y]
      existingSegment.added = true

    else
      segment = [start, end]
      segment.added = true

      @segments.push segment

      @segmentsMap[start.x] ?= {}
      @segmentsMap[start.x][start.y] ?= {}
      @segmentsMap[start.x][start.y][end.x] ?= {}
      @segmentsMap[start.x][start.y][end.x][end.y] = segment

      @changed = true

    @_addVertex start
    @_addVertex end

  _addVertex: (vertex) ->
    return if @findVertex vertex.x, vertex.y

    @vertices.push vertex

    @verticesMap[vertex.x] ?= {}
    @verticesMap[vertex.x][vertex.y] = vertex

  findVertex: (x, y) ->
    @verticesMap[x]?[y]
