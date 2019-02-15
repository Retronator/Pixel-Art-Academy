LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver.Polyhedron.Cluster
  @PointTypes:
    Pixel: 0
    Edge: 1
    Void: 2
    Extra: 3

  @PointTypeColors: [
    [176 / 255, 60 / 255, 60 / 255]
    [188 / 255, 140 / 255, 76 / 255]
    [108 / 255, 108 / 255, 108 / 255]
    [160 / 255, 160 / 255, 52 / 255]
  ]

  constructor: (@layerCluster) ->
    @id = @layerCluster.id
    @pictureCluster = @layerCluster.layer.findPictureCluster @id
    @picture = @pictureCluster.picture

    @edges = {}

    @plane =
      point: null
      normal: null
      matrix: null
      matrixInverse: null
      
    @points = []
    @indices = []
    
    @origin =
      x: @picture.bounds?.x or 0
      y: @picture.bounds?.y or 0

    @recomputePixels = true
    @recomputeEdges = true

    @startRecomputation()

  startRecomputation: ->
    @pixelsChanged = false
    @edgesChanged = false
    @planeChanged = false

  changed: ->
    @pixelsChanged or @edgesChanged or @planeChanged

  setPlaneNormal: (normal) ->
    unless @plane.normal?.equals normal
      @plane.normal = THREE.Vector3.fromObject normal
      @planeChanged = true

  setPlanePoint: (point) ->
    unless @plane.point?.equals point
      @plane.point = THREE.Vector3.fromObject point
      @planeChanged = true
      
  getPlane: ->
    return unless @plane.point and @plane.normal

    new THREE.Plane().setFromNormalAndCoplanarPoint @plane.normal, @plane.point

  updatePixels: ->
    @properties = @pictureCluster.properties
    @setPlaneNormal @properties.normal
    
    # Create map for fast retrieval.
    @pixels = []
    @pixelMap = {}

    bounds = @picture.bounds()

    clusterIdMap = @picture.getMap LOI.Assets.Mesh.Object.Layer.Picture.Map.Types.ClusterId

    for x in [0...bounds.width]
      for y in [0...bounds.height]
        continue unless @id is clusterIdMap.getPixel x, y

        absoluteX = x + bounds.x
        absoluteY = y + bounds.y

        pixel = _.extend
          x: absoluteX
          y: absoluteY
        ,
          @picture.getMapValuesForPixelRelative x, y

        @pixels.push pixel

        @pixelMap[absoluteX] ?= {}
        @pixelMap[absoluteX][absoluteY] = pixel

    # Mark edges.
    for x, column of @pixelMap
      for y, pixel of column
        pixel.clusterNeighbors =
          left: @pixelMap[pixel.x - 1]?[pixel.y]
          right: @pixelMap[pixel.x + 1]?[pixel.y]
          up: @pixelMap[pixel.x]?[pixel.y - 1]
          down: @pixelMap[pixel.x]?[pixel.y + 1]

        pixel.clusterEdges = {}

        # Edge is on each side that doesn't have a neighbor.
        for side in ['left', 'right', 'up', 'down']
          pixel.clusterEdges[side] = not pixel.clusterNeighbors[side]

    @recomputePixels = false
    @pixelsChanged = true
    
  addEdge: (edge) ->
    otherCluster = edge.getOtherCluster @
    @edges[otherCluster.id] = edge
    @edgesChanged = true
    
  removeEdge: (edge) ->
    otherCluster = edge.getOtherCluster @
    delete @edges[otherCluster.id]
    @edgesChanged = true

  getAbsolutePixelCoordinates: (pixel) ->
    x: pixel.x + @origin.x
    y: pixel.y + @origin.y

  findPixelAtAbsoluteCoordinate: (absoluteX, absoluteY) ->
    x = Math.floor absoluteX - @origin.x
    y = Math.floor absoluteY - @origin.y
    
    @pixelMap[x]?[y]

  getPoints: (options) ->
    elementsPerVertex = 3
    verticesArray = new Float32Array @points.length * elementsPerVertex
    colorsArray = new Float32Array @points.length * elementsPerVertex

    meshData = options.meshData()
    palette = meshData.customPalette or LOI.Assets.Palette.documents.findOne meshData.palette._id
    paletteColor = @properties.paletteColor
    color = palette.ramps[paletteColor.ramp].shades[paletteColor.shade]

    for point, index in @points
      verticesArray[index * elementsPerVertex] = point.vertex.x
      verticesArray[index * elementsPerVertex + 1] = point.vertex.y
      verticesArray[index * elementsPerVertex + 2] = point.vertex.z

      if point.type is @constructor.PointTypes.Pixel
        colorsArray[index * elementsPerVertex] = color.r
        colorsArray[index * elementsPerVertex + 1] = color.g
        colorsArray[index * elementsPerVertex + 2] = color.b

      else
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

  generateGeometry: (options) ->
    elementsPerVertex = 3
    vertices = new Float32Array @points.length * elementsPerVertex
    normals = new Float32Array @points.length * elementsPerVertex
    indices = new Uint32Array @indices

    nanWarned = false

    for point, index in @points
      vertices[index * elementsPerVertex] = point.vertex.x
      vertices[index * elementsPerVertex + 1] = point.vertex.y
      vertices[index * elementsPerVertex + 2] = point.vertex.z

      normals[index * elementsPerVertex] = @plane.normal.x
      normals[index * elementsPerVertex + 1] = @plane.normal.y
      normals[index * elementsPerVertex + 2] = @plane.normal.z

      if not nanWarned and _.isNaN point.vertex.x
        console.warn "Cluster on layer #{@picture.layer.name()} has invalid vertices at", index, @
        nanWarned = true

    {vertices, normals, indices}
