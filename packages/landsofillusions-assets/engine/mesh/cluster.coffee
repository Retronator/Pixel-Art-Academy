LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Cluster
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
    x = Math.floor x
    y = Math.floor y

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

  getMesh: (options = {}) ->
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
    geometry.setIndex @indices

    # Determine the color.
    meshData = options.meshData()
    palette = meshData.customPalette or LOI.Assets.Palette.documents.findOne meshData.palette._id
    pixel = @pixels[0]
    materialsData = options.materialsData?()
    visualizeNormals = options.visualizeNormals?()

    material = null
    
    materialOptions =
      wireframe: options.debug()

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

      if paletteColor
        shades = palette.ramps[paletteColor.ramp].shades
        shadeIndex = THREE.Math.clamp paletteColor.shade, 0, shades.length - 1
        material = new LOI.Assets.Engine.Mesh.RampMaterial _.extend materialOptions, {shades, shadeIndex}
        
      else
        material = new THREE.MeshLambertMaterial _.extend materialOptions,
          color: THREE.Color.fromObject pixel.directColor

    mesh = new THREE.Mesh geometry, material

    mesh.castShadow = true
    mesh.receiveShadow = true

    mesh
