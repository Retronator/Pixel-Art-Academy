LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver.Organic.IslandPart
  constructor: (initialCluster) ->
    @clusters = []

    # Flood fill all neighboring clusters.
    clustersFringe = [initialCluster]

    while clustersFringe.length
      cluster = clustersFringe.pop()

      # Nothing to do if this cluster is already assigned to us.
      continue if cluster.islandPart is @

      # Assign this cluster to us and add all its neighbors to the fringe.
      cluster.islandPart = @
      clustersFringe.push _.values(cluster.neighbors)...

  determineEdges: (islandParts) ->
    for cluster in @clusters
