LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Cluster
  @PointTypes:
    Pixel: 0
    Edge: 1
    Void: 2

  @PointTypeColors: [
    [176 / 255, 60 / 255, 60 / 255]
    [188 / 255, 140 / 255, 76 / 255]
    [108 / 255, 108 / 255, 108 / 255]
  ]

  constructor: (@index) ->
    @pixels = []
    @edges = []

    @plane =
      point: null
      normal: null
      
    @points = []

  getPlane: ->
    new THREE.Plane().setFromNormalAndCoplanarPoint @plane.normal, @plane.point

  process: ->
    @plane.normal = THREE.Vector3.fromObject @pixels[0].normal

  findPixelAtCoordinate: (x, y) ->
    _.find @pixels, (pixel) => pixel.x is x and pixel.y is y

  getPoints: ->
    elementsPerVertex = 3
    verticesArray = new Float32Array @points.length * elementsPerVertex
    colorsArray = new Float32Array @points.length * elementsPerVertex

    for point, index in @points
      verticesArray[index * elementsPerVertex] = point.vertex.x
      verticesArray[index * elementsPerVertex + 1] = point.vertex.y
      verticesArray[index * elementsPerVertex + 2] = point.vertex.z

      for offset in [0..2]
        colorsArray[index * elementsPerVertex + offset] = @constructor.PointTypeColors[point.type][offset]

    geometry = new THREE.BufferGeometry
    geometry.addAttribute 'position', new THREE.BufferAttribute verticesArray, elementsPerVertex
    geometry.addAttribute 'color', new THREE.BufferAttribute colorsArray, elementsPerVertex

    material = new THREE.PointsMaterial
      size: 0.1
      vertexColors: THREE.VertexColors

    new THREE.Points geometry, material
