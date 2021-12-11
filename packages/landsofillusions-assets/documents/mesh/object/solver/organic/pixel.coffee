LOI = LandsOfIllusions
OrganicSolver = LOI.Assets.Mesh.Object.Solver.Organic

class OrganicSolver.Pixel
  @sides =
    up: opposite: 'down', direction: new THREE.Vector2 0, -1
    down: opposite: 'up', direction: new THREE.Vector2 0, 1
    left: opposite: 'right', direction: new THREE.Vector2 -1, 0
    right: opposite: 'left', direction: new THREE.Vector2 1, 0
    leftUp: opposite: 'rightDown', direction: new THREE.Vector2 -1, -1
    rightUp: opposite: 'leftDown', direction: new THREE.Vector2 1, -1
    leftDown: opposite: 'rightUp', direction: new THREE.Vector2 -1, 1
    rightDown: opposite: 'leftUp', direction: new THREE.Vector2 1, 1

  @sideProperties = _.keys @sides

  constructor: (@x, @y, @cluster) ->
    @clusterNeighbors =
      left: @cluster.pixelsMap[@x - 1]?[@y]
      right: @cluster.pixelsMap[@x + 1]?[@y]
      up: @cluster.pixelsMap[@x]?[@y - 1]
      down: @cluster.pixelsMap[@x]?[@y + 1]
      leftUp: @cluster.pixelsMap[@x - 1]?[@y - 1]
      rightUp: @cluster.pixelsMap[@x + 1]?[@y - 1]
      leftDown: @cluster.pixelsMap[@x - 1]?[@y + 1]
      rightDown: @cluster.pixelsMap[@x + 1]?[@y + 1]

    # Link cluster neighbors to us.
    for side, clusterNeighbor in @clusterNeighbors when clusterNeighbor
      oppositeSide = @constructor.sides[side].opposite
      clusterNeighbor.setClusterNeighbor oppositeSide, @

    @isClusterEdge = {}

    # The cluster ends on each side that doesn't have a neighbor.
    for side in @sideProperties
      @isClusterEdge[side] = not @clusterNeighbors[side]

    @neighbors = _.clone @clusterNeighbors
    @isEdge = _.clone @isClusterEdge

    @depthCalculationIteration = 0

  setClusterNeighbor: (side, pixel) ->
    @clusterNeighbors[side] = pixel
    @isClusterEdge[side] = false

  detachFromNeighbors: ->
    for side, neighbor of @neighbors
      neighbor.detachNeighbor @

  detachNeighbor: (detachingNeighbor) ->
    for side, neighbor of @neighbors when neighbor is detachingNeighbor
      @neighbors[side] = null

    for side, clusterNeighbor of @clusterNeighbors when clusterNeighbor is detachingNeighbor
      @clusterNeighbors[side] = null

  getNeighborCoordinates: (side) ->
    direction = @constructor.sides[side].direction

    x: @x + direction.x
    y: @y + direction.y

  setNeighbor: (side, pixel) ->
    @neighbors[side] = pixel
    @isEdge[side] = false

  isPictureEdgeTowards: (pixel) ->
    # There is an edge between this pixel and the target if there is no pixel at target in the same picture.
    not @cluster.picture.pixelExists pixel.x, pixel.y
