LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Cluster
  constructor: (@index) ->
    @pixels = []
    @edges = []

  findPixelAtCoordinate: (x, y) ->
    _.find @pixels, (pixel) => pixel.x is x and pixel.y is y
