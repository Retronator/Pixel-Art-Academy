LOI = LandsOfIllusions
OrganicSolver = LOI.Assets.Mesh.Object.Solver.Organic

OrganicSolver::computeIslandPartBorders = (islandParts) ->
  console.log "Computing borders of island parts" if OrganicSolver.debug

  for islandPartIndexA in [0...islandParts.length - 1]
    islandPartA = islandParts[islandPartIndexA]
    
    for islandPartIndexB in [islandPartIndexA + 1...islandParts.length]
      islandPartB = islandParts[islandPartIndexB]
      existingEdge = islandPartA.borders[islandPartB.id]

      # We only detect/update edges between islandParts where either demands recomputation.
      unless islandPartA.recomputeEdges or islandPartB.recomputeEdges
        # This existing edge won't change, so we can add it to the list of all edges.
        allEdges.push existingEdge if existingEdge
        continue

      # Start computation of the edge.
      if existingEdge
        edge = existingEdge
        edge.startRecomputation()
        
      else
        edge = new LOI.Assets.Mesh.Object.Solver.Polyhedron.Edge islandPartA, islandPartB

        # We do not allow edges between islandParts facing opposite directions.
        continue unless edge.line.direction.length() or islandPartA.plane.normal.dot(islandPartB.plane.normal) > 0

      for pixel in islandPartA.pixels
        coordinates = islandPartA.getAbsolutePixelCoordinates pixel

        # Detect edges with neighboring pixels on all 4 sides. Edge vertices are directed
        # so that islandPart A is on the right of the segment, islandPart B on the left.
        if pixel.islandPartEdges.left and islandPartB.findPixelAtAbsoluteCoordinate(coordinates.x - 1, coordinates.y)?.islandPartEdges.right
          edge.addSegment coordinates, 0, 1, 0, 0

        if pixel.islandPartEdges.right and islandPartB.findPixelAtAbsoluteCoordinate(coordinates.x + 1, coordinates.y)?.islandPartEdges.left
          edge.addSegment coordinates, 1, 0, 1, 1

        if pixel.islandPartEdges.up and islandPartB.findPixelAtAbsoluteCoordinate(coordinates.x, coordinates.y - 1)?.islandPartEdges.down
          edge.addSegment coordinates, 0, 0, 1, 0

        if pixel.islandPartEdges.down and islandPartB.findPixelAtAbsoluteCoordinate(coordinates.x, coordinates.y + 1)?.islandPartEdges.up
          edge.addSegment coordinates, 1, 1, 0, 1

        # Detect edges with overlapping pixels.
        if pixel.islandPartEdges.left and islandPartB.findPixelAtAbsoluteCoordinate(coordinates.x , coordinates.y)?.islandPartEdges.left
          edge.addSegment coordinates, 0, 1, 0, 0

        if pixel.islandPartEdges.right and islandPartB.findPixelAtAbsoluteCoordinate(coordinates.x, coordinates.y)?.islandPartEdges.right
          edge.addSegment coordinates, 1, 0, 1, 1

        if pixel.islandPartEdges.up and islandPartB.findPixelAtAbsoluteCoordinate(coordinates.x, coordinates.y)?.islandPartEdges.up
          edge.addSegment coordinates, 0, 0, 1, 0

        if pixel.islandPartEdges.down and islandPartB.findPixelAtAbsoluteCoordinate(coordinates.x, coordinates.y)?.islandPartEdges.down
          edge.addSegment coordinates, 1, 1, 0, 1

      edge.endRecomputation()

      if existingEdge and not edge.segments.length
        # Edge between these islandParts does not exist anymore.
        console.log "No more edge between islandParts #{islandPartA.id} and #{islandPartB.id}.", edge if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

        edge.removeFromislandParts()

      else if not existingEdge and edge.segments.length
        # A new edge was found.
        console.log "Found edge between islandParts #{islandPartA.id} and #{islandPartB.id}.", edge if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

        edge.addToislandParts()

      # Process changed edges.
      if edge.changed
        console.log "Edge between islandParts #{islandPartA.id} and #{islandPartB.id} has changed.", edge if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

        edge.determineParallelislandParts()
        edge.reportChangeToislandParts()

      # If the edge has any segments, it is a valid edge and will be part of the topology.
      allEdges.push edge if edge.segments.length

  console.log "All detected edges are", allEdges if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

  # Filter out small edges that overlap longer edges. These usually appear on jaggies of overlapping islandParts.
  finalEdges = []

  allEdges = _.sortBy allEdges, (edge) => edge.segments.length

  for edge in allEdges
    # See if this edge is contained in either islandParts' other edges.
    containedWithinEdge = null

    for islandPart in [edge.islandPartA, edge.islandPartB]
      otherislandPart = edge.getOtherislandPart islandPart

      # Only delete edges based on other straight edges (not coplanar).
      for neighborislandPartId, neighborEdge of islandPart.edges when neighborEdge isnt edge
        # Parallel edges should not be considered for removal of other edges.
        continue if neighborEdge.parallelislandParts

        # Also make sure the two other islandParts aren't parallel.
        if otherislandPart.edges[neighborislandPartId]?.parallelislandParts
          continue

        # Parallel edge segments do not have priority and should be deleted where overlapping other straight edges.
        if edge.parallelislandParts
          # Throw out any of the segments that are part of another edge.
          _.remove edge.segments, (segment) => neighborEdge.segmentsMap[segment[0].x]?[segment[0].y]?[segment[1].x]?[segment[1].y] or neighborEdge.segmentsMap[segment[1].x]?[segment[1].y]?[segment[0].x]?[segment[0].y]

          # If no more segments remain, the coplanar edge was completely contained in other edges.
          unless edge.segments.length
            containedWithinEdge = neighborEdge

        else
          contained = true

          for segment in edge.segments
            unless neighborEdge.segmentsMap[segment[0].x]?[segment[0].y]?[segment[1].x]?[segment[1].y] or neighborEdge.segmentsMap[segment[1].x]?[segment[1].y]?[segment[0].x]?[segment[0].y]
              contained = false
              break

          if contained
            containedWithinEdge = neighborEdge

      break if containedWithinEdge

    if containedWithinEdge
      edge.removeFromislandParts()
      console.log "Filtering edge between islandParts #{edge.islandPartA.id} and #{edge.islandPartB.id} as it is contained within edge between islandParts #{containedWithinEdge.islandPartA.id} and #{containedWithinEdge.islandPartB.id} .", edge, containedWithinEdge if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

    else
      finalEdges.push edge

  console.log "Final edges in topology are", finalEdges if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
  
  islandPart.recomputeEdges = false for islandPart in recomputeEdgesislandParts

  finalEdges
