LOI = LandsOfIllusions
OrganicSolver = LOI.Assets.Mesh.Object.Solver.Organic

class OrganicSolver.Island
  constructor: (initialCluster) ->
    @clusters = []

    # Flood fill all neighboring clusters.
    clustersFringe = [initialCluster]

    while clustersFringe.length
      cluster = clustersFringe.pop()

      # Nothing to do if this cluster is already assigned to us.
      continue if cluster.island is @

      # Assign this cluster to us and add all its neighbors to the fringe.
      cluster.island = @
      clustersFringe.push _.values(cluster.neighbors)...

  determineOriginPixel: ->
    @originPixel = @clusters[0].pixels[0]

  calculateDepth: (depthCalculationIteration) ->
    # Start at the origin pixel and calculate depth in a breadth-first fashion.
    @originPixel.setDepth 0
    @originPixel.depthCalculationIteration = depthCalculationIteration

    fringe = []
    addNeighborsToFringe = (pixel) ->
      for side of OrganicSolver.Pixel.sides
        if neighbor = @neighbors[side]
          # Only pixels that haven't been calculated at this iteration need to be added.
          if neighbor.depthCalculationIteration < depthCalculationIteration
            fringe.push neighbor

    addNeighborsToFringe @originPixel

    # Keep calculating depth until all pixels of the island have been reached.
    while fringe.length
      pixel = fringe.shift()
      pixel.calculateDepth()
      pixel.depthCalculationIteration = depthCalculationIteration
      addNeighborsToFringe pixel
