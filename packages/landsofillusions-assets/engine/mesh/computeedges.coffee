LOI = LandsOfIllusions

LOI.Assets.Engine.Mesh.computeEdges = (clusters) ->
  edges = []
  return edges unless clusters.length

  console.log "Computing edges between clusters", clusters if LOI.Assets.Engine.Mesh.debug

  for clusterIndexA in [0...clusters.length - 1]
    for clusterIndexB in [clusterIndexA + 1...clusters.length]
      # Detect an edge between the two clusters.
      clusterA = clusters[clusterIndexA]
      clusterB = clusters[clusterIndexB]
      
      edge = new LOI.Assets.Engine.Mesh.Edge clusterA, clusterB
        
      for pixel in clusterA.pixels
        # Note: Edge vertices are directed so that cluster A is on the right of the segment, cluster B on the left.
        edge.addSegment pixel, 0, 1, 0, 0 if pixel.left?.cluster is clusterB
        edge.addSegment pixel, 1, 0, 1, 1 if pixel.right?.cluster is clusterB
        edge.addSegment pixel, 0, 0, 1, 0 if pixel.up?.cluster is clusterB
        edge.addSegment pixel, 1, 1, 0, 1 if pixel.down?.cluster is clusterB

      console.log "Computed edge between clusters #{clusterIndexA} and #{clusterIndexB}", edge if LOI.Assets.Engine.Mesh.debug
        
      # See if we found any neighbors.
      continue unless edge.segments.length

      edges.push edge
      clusterA.edges.push edge
      clusterB.edges.push edge

  console.log "Created edges", edges if LOI.Assets.Engine.Mesh.debug

  edges
