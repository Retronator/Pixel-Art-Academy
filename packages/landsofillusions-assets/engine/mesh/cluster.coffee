LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Cluster
  constructor: (@index) ->
    @pixels = []
    @edges = []

    @plane =
      point: null
      normal: null

  getPlane: ->
    new THREE.Plane().setFromNormalAndCoplanarPoint @plane.normal, @plane.point

  process: ->
    @plane.normal = THREE.Vector3.fromObject @pixels[0].normal

  findPixelAtCoordinate: (x, y) ->
    _.find @pixels, (pixel) => pixel.x is x and pixel.y is y
