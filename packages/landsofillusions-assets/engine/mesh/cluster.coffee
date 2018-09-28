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
      matrix: null
      matrixInverse: null
      
    @points = []
    @indices = []

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
      size: 5
      vertexColors: THREE.VertexColors
      sizeAttenuation: false

    new THREE.Points geometry, material

  getMesh: (wireframe = false) ->
    elementsPerVertex = 3
    verticesArray = new Float32Array @points.length * elementsPerVertex
    normalsArray = new Float32Array @points.length * elementsPerVertex

    for point, index in @points
      verticesArray[index * elementsPerVertex] = point.vertex.x
      verticesArray[index * elementsPerVertex + 1] = point.vertex.y
      verticesArray[index * elementsPerVertex + 2] = point.vertex.z

      normalsArray[index * elementsPerVertex] = @plane.normal.x
      normalsArray[index * elementsPerVertex + 1] = @plane.normal.y
      normalsArray[index * elementsPerVertex + 2] = @plane.normal.z

    geometry = new THREE.BufferGeometry
    geometry.addAttribute 'position', new THREE.BufferAttribute verticesArray, elementsPerVertex
    geometry.addAttribute 'normal', new THREE.BufferAttribute normalsArray, elementsPerVertex
    geometry.setIndex new THREE.BufferAttribute @indices, 3

    material = new THREE.MeshBasicMaterial
      color: 0xffffff
      wireframe: wireframe

    new THREE.Mesh geometry, material
