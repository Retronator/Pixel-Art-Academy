LOI = LandsOfIllusions
OrganicSolver = LOI.Assets.Mesh.Object.Solver.Organic

class OrganicSolver.Island.Part
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

    @contour = new OrganicSolver.Island.Part.Contour @

  initialize: (@id) ->
    @borders = {}

  recomputeContour: ->
    # Add all contour segments of this island part.
    @contour.startRecomputation()

    for cluster in @clusters
      for pixel in cluster.pixels
        coordinates = cluster.getAbsolutePixelCoordinates pixel

        # Detect edges on all 4 sides. Edge vertices are directed
        # so that the island part is on the right of the segment.
        @contour.addSegment coordinates, 0, 1, 0, 0 if pixel.isEdge.left
        @contour.addSegment coordinates, 1, 0, 1, 1 if pixel.isEdge.right
        @contour.addSegment coordinates, 0, 0, 1, 0 if pixel.isEdge.up
        @contour.addSegment coordinates, 1, 1, 0, 1 if pixel.isEdge.down

    @contour.endRecomputation()
