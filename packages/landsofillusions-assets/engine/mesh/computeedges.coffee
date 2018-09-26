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
        
      # Analyze all neighbors of the smaller cluster.
      smallerCluster = if clusterA.pixels.length < clusterB.pixels.length then clusterA else clusterB
      biggerCluster = if smallerCluster is clusterA then clusterB else clusterA
        
      for pixel in smallerCluster.pixels
        edge.addVertices pixel, 0, 0, 0, 1 if pixel.left?.cluster is biggerCluster
        edge.addVertices pixel, 1, 0, 1, 1 if pixel.right?.cluster is biggerCluster
        edge.addVertices pixel, 0, 0, 1, 0 if pixel.up?.cluster is biggerCluster
        edge.addVertices pixel, 0, 1, 1, 1 if pixel.down?.cluster is biggerCluster

      console.log "Computed edge between clusters #{clusterIndexA} and #{clusterIndexB}", edge if LOI.Assets.Engine.Mesh.debug
        
      # See if we found any neighbors.
      continue unless edge.vertices.length

      # All vertices have been added so let the edge process its structures.
      edge.process()

      edges.push edge
      clusterA.edges.push edge
      clusterB.edges.push edge

  console.log "Created edges", edges if LOI.Assets.Engine.Mesh.debug

  edges
