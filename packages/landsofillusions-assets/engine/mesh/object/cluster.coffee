LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Object.Cluster
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

  constructor: (@index, @picture, @pixelProperties) ->
    @pixels = []
    @edges = []

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

  getPlane: ->
    new THREE.Plane().setFromNormalAndCoplanarPoint @plane.normal, @plane.point

  process: ->
    @plane.normal = THREE.Vector3.fromObject @pixelProperties.normal
    
    # Create map for fast retrieval.
    @pixelMap = {}
    
    for pixel in @pixels
      @pixelMap[pixel.x] ?= {}
      @pixelMap[pixel.x][pixel.y] = pixel

    # Mark edges.
    for pixel in @pixels
      pixel.clusterNeighbors =
        left: @pixelMap[pixel.x - 1]?[pixel.y]
        right: @pixelMap[pixel.x + 1]?[pixel.y]
        up: @pixelMap[pixel.x]?[pixel.y - 1]
        down:  @pixelMap[pixel.x]?[pixel.y + 1]
        
      pixel.clusterEdges = {}

      # Edge is on each side that doesn't have a neighbor.
      for side in ['left', 'right', 'up', 'down']
        pixel.clusterEdges[side] = not pixel.clusterNeighbors[side]

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
    paletteColor = @pixelProperties.paletteColor
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

  getMesh: (options) ->
    return unless meshData = options.meshData()
    return unless palette = meshData.customPalette or LOI.Assets.Palette.documents.findOne meshData.palette._id

    elementsPerVertex = 3
    verticesArray = new Float32Array @points.length * elementsPerVertex
    normalsArray = new Float32Array @points.length * elementsPerVertex

    nanWarned = false

    for point, index in @points
      verticesArray[index * elementsPerVertex] = point.vertex.x
      verticesArray[index * elementsPerVertex + 1] = point.vertex.y
      verticesArray[index * elementsPerVertex + 2] = point.vertex.z

      normalsArray[index * elementsPerVertex] = @plane.normal.x
      normalsArray[index * elementsPerVertex + 1] = @plane.normal.y
      normalsArray[index * elementsPerVertex + 2] = @plane.normal.z

      if not nanWarned and _.isNaN point.vertex.x
        console.warn "Cluster on layer #{@picture.layer.name()} has invalid vertices at", index, @
        nanWarned = true

    geometry = new THREE.BufferGeometry
    geometry.addAttribute 'position', new THREE.BufferAttribute verticesArray, elementsPerVertex
    geometry.addAttribute 'normal', new THREE.BufferAttribute normalsArray, elementsPerVertex
    geometry.setIndex @indices

    # Determine the color.
    pixel = @pixelProperties
    materialsData = options.materialsData?()
    visualizeNormals = options.visualizeNormals?()

    material = null
    
    materialOptions =
      wireframe: options.debug?()

    if visualizeNormals
      # Visualized normals mode.
      if pixel.normal
        normal = new THREE.Vector3 pixel.normal.x, pixel.normal.y, pixel.normal.z
        backward = new THREE.Vector3 0, 0, 1

        horizontalAngle = Math.atan2(normal.y, normal.x) + Math.PI
        verticalAngle = normal.angleTo backward

        hue = horizontalAngle / (2 * Math.PI)
        saturation = verticalAngle / (Math.PI / 2)

        directColor = new THREE.Color().setHSL hue, saturation, 0.5

      else
        directColor = r: 0, g: 0, b: 0

      material = new THREE.MeshBasicMaterial _.extend materialOptions,
        color: THREE.Color.fromObject directColor

    else
      paletteColor = null

      # Normal color mode.
      if pixel.materialIndex?
        material = options.meshData.materials[pixel.materialIndex]

        paletteColor = _.clone material

        # Override material data if we have it present.
        if materialData = materialsData?[material.name]
          for key, value of materialData
            paletteColor[key] = value if value?

      else if pixel.paletteColor
        paletteColor = pixel.paletteColor

      if paletteColor and palette.ramps[paletteColor.ramp]
        shades = palette.ramps[paletteColor.ramp]?.shades
        shadeIndex = THREE.Math.clamp paletteColor.shade, 0, shades.length - 1

        if materialOptions.wireframe
          material = new THREE.MeshBasicMaterial _.extend materialOptions,
            color: THREE.Color.fromObject shades[paletteColor.shade]

        else
          material = new LOI.Assets.Engine.Mesh.Object.RampMaterial _.extend materialOptions, {shades, shadeIndex}

      else if pixel.directColor
        material = new THREE.MeshLambertMaterial _.extend materialOptions,
          color: THREE.Color.fromObject pixel.directColor

      else
        material = new THREE.MeshLambertMaterial _.extend materialOptions,
          color: new THREE.Color 0xffffff

    mesh = new THREE.Mesh geometry, material

    mesh.castShadow = true
    mesh.receiveShadow = true
    mesh.material.shadowSide = THREE.DoubleSide

    mesh
