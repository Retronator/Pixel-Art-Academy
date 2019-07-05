LOI = LandsOfIllusions

LOI.Assets.Mesh.Object.Solver.Polyhedron::computeEdges = (clusters) ->
  allEdges = []
  return allEdges unless clusters.length

  recomputeEdgesClusters = _.filter clusters, (cluster) => cluster.recomputeEdges
  
  console.log "Computing edges of clusters", recomputeEdgesClusters if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

  for clusterIndexA in [0...clusters.length - 1]
    clusterA = clusters[clusterIndexA]
    
    for clusterIndexB in [clusterIndexA + 1...clusters.length]
      clusterB = clusters[clusterIndexB]
      existingEdge = clusterA.edges[clusterB.id]

      # We only detect/update edges between clusters where either demands recomputation.
      unless clusterA.recomputeEdges or clusterB.recomputeEdges
        # This existing edge won't change, so we can add it to the list of all edges.
        allEdges.push existingEdge if existingEdge
        continue

      # Start computation of the edge.
      if existingEdge
        edge = existingEdge
        edge.startRecomputation()
        
      else
        edge = new LOI.Assets.Mesh.Object.Solver.Polyhedron.Edge clusterA, clusterB

        # We do not allow edges between clusters facing opposite directions.
        continue unless edge.line.direction.length() or clusterA.plane.normal.dot(clusterB.plane.normal) > 0

      for pixel in clusterA.pixels
        coordinates = clusterA.getAbsolutePixelCoordinates pixel

        # Detect edges with neighboring pixels on all 4 sides. Edge vertices are directed
        # so that cluster A is on the right of the segment, cluster B on the left.
        if pixel.clusterEdges.left and clusterB.findPixelAtAbsoluteCoordinate(coordinates.x - 1, coordinates.y)?.clusterEdges.right
          edge.addSegment coordinates, 0, 1, 0, 0

        if pixel.clusterEdges.right and clusterB.findPixelAtAbsoluteCoordinate(coordinates.x + 1, coordinates.y)?.clusterEdges.left
          edge.addSegment coordinates, 1, 0, 1, 1

        if pixel.clusterEdges.up and clusterB.findPixelAtAbsoluteCoordinate(coordinates.x, coordinates.y - 1)?.clusterEdges.down
          edge.addSegment coordinates, 0, 0, 1, 0

        if pixel.clusterEdges.down and clusterB.findPixelAtAbsoluteCoordinate(coordinates.x, coordinates.y + 1)?.clusterEdges.up
          edge.addSegment coordinates, 1, 1, 0, 1

        # Detect edges with overlapping pixels.
        if pixel.clusterEdges.left and clusterB.findPixelAtAbsoluteCoordinate(coordinates.x , coordinates.y)?.clusterEdges.left
          edge.addSegment coordinates, 0, 1, 0, 0

        if pixel.clusterEdges.right and clusterB.findPixelAtAbsoluteCoordinate(coordinates.x, coordinates.y)?.clusterEdges.right
          edge.addSegment coordinates, 1, 0, 1, 1

        if pixel.clusterEdges.up and clusterB.findPixelAtAbsoluteCoordinate(coordinates.x, coordinates.y)?.clusterEdges.up
          edge.addSegment coordinates, 0, 0, 1, 0

        if pixel.clusterEdges.down and clusterB.findPixelAtAbsoluteCoordinate(coordinates.x, coordinates.y)?.clusterEdges.down
          edge.addSegment coordinates, 1, 1, 0, 1

      edge.endRecomputation()

      if existingEdge and not edge.segments.length
        # Edge between these clusters does not exist anymore.
        console.log "No more edge between clusters #{clusterA.id} and #{clusterB.id}.", edge if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

        edge.removeFromClusters()

      else if not existingEdge and edge.segments.length
        # A new edge was found.
        console.log "Found edge between clusters #{clusterA.id} and #{clusterB.id}.", edge if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

        edge.addToClusters()

      # Process changed edges.
      if edge.changed
        console.log "Edge between clusters #{clusterA.id} and #{clusterB.id} has changed.", edge if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

        edge.process()
        edge.reportChangeToClusters()

      # If the edge has any segments, it is a valid edge and will be part of the topology.
      allEdges.push edge if edge.segments.length

  console.log "All detected edges are", allEdges if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

  # Filter out small edges that overlap longer edges. These usually appear on jaggies of overlapping clusters.
  finalEdges = []

  allEdges = _.sortBy allEdges, (edge) => edge.segments.length

  for edge in allEdges
    # See if this edge is contained in either clusters' other edges.
    containedWithinEdge = null

    for cluster in [edge.clusterA, edge.clusterB]
      for otherClusterId, otherEdge of cluster.edges when otherEdge isnt edge
        contained = true

        for segment in edge.segments
          unless otherEdge.segmentsMap[segment[0].x]?[segment[0].y]?[segment[1].x]?[segment[1].y]
            contained = false
            break

        if contained
          containedWithinEdge = otherEdge

      break if containedWithinEdge

    if containedWithinEdge
      edge.removeFromClusters()
      console.log "Filtering edge between clusters #{edge.clusterA.id} and #{edge.clusterB.id} as it is contained within edge between clusters #{containedWithinEdge.clusterA.id} and #{containedWithinEdge.clusterB.id} .", edge, containedWithinEdge if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

    else
      finalEdges.push edge

  console.log "Final edges in topology are", finalEdges if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
  
  cluster.recomputeEdges = false for cluster in recomputeEdgesClusters

  finalEdges
