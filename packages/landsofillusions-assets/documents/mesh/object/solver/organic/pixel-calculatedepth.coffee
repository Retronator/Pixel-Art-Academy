LOI = LandsOfIllusions
OrganicSolver = LOI.Assets.Mesh.Object.Solver.Organic

class OrganicSolver.Pixel extends OrganicSolver.Pixel
  updateNormal: ->
    @normal = @cluster.picture.getMapValueForPixel LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.Normal, x, y

    # Update the plane constant if the depth has already been determined.
    @_updateNormalPlaneConstant() if @z?

  setDepth: (@z) ->
    # Also update the plane constant.
    @_updateNormalPlaneConstant()

  _updateNormalPlaneConstant: ->
    @normalPlaneConstant = -@normal.x * @x - @normal.y * @y - @normal.z * @z

  calculateDepth: ->
    # Gather depth estimation from all neighbors that have their depth calculated at least once.
    estimatesSum = 0
    estimatesCount = 0

    for side of OrganicSolver.Pixel.sides
      if neighbor = @neighbors[side]
        if neighbor.depthCalculationIteration > 0
          estimatesCount++
          estimatesSum += neighbor.interpolateDepthAt @x, @y

    # Depth is the average of all estimates.
    @setDepth estimatesSum / estimatesCount

  interpolateDepthAt: (x, y) ->
    (-@normal.x * x - @normal.y * y - @normalPlaneConstant) / @normal.z
