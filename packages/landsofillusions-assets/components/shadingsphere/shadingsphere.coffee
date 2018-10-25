AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.ShadingSphere extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.ShadingSphere'

  constructor: (@options) ->
    super arguments...

    @currentNormal = new ReactiveField new THREE.Vector3 0, 0, 1

    @editLight = new ReactiveField false
    @angleSnap = new ReactiveField @options.initialAngleSnap

    @pixelCanvas = new ReactiveField null

    @sphereSpriteGeometry = new ComputedField =>
      # Construct the sphere sprite.
      return unless radius = @options.radius()
      angleSnap = @angleSnap()

      bounds = new AE.Rectangle(
        left: Math.floor -radius
        top: Math.floor -radius
        right: Math.ceil radius - 1
        bottom: Math.ceil radius - 1
      ).toObject()

      # Correct width and height to whole pixel dimensions.
      bounds.width++
      bounds.height++

      materialIndex = 0

      pixels = []

      for x in [bounds.left..bounds.right]
        for y in [bounds.top..bounds.bottom]
          pixelCenter = new THREE.Vector2 x + 0.5, y + 0.5
          continue if pixelCenter.length() > radius

          normal = @canvasCoordinateToNormal pixelCenter, angleSnap
          
          pixels.push {x, y, normal, materialIndex}

      layers: [pixels: pixels]
      bounds: bounds

    @sphereSpriteData = new ComputedField =>
      return unless spriteData = @sphereSpriteGeometry()

      # Add palette information to sprite.
      palette = @options.palette()
      visualizeNormals = @options.visualizeNormals()
      paletteId = palette.options.paletteId()

      if visualizeNormals
        # Just return the sprite without any extra color information.
        spriteData

      else if paletteId
        spriteData.palette =
          _id: paletteId

        # Get the ramp and shade we're using.
        material =
          ramp: palette.currentRamp()
          shade: palette.currentShade()

        # See if we're setting a named color.
        materialIndex = @options.materials().currentIndex()

        if materialIndex?
          assetData = @options.materials().assetData()
          material = assetData.materials?[materialIndex]

        return unless material?.ramp? and material?.shade?

        spriteData.materials = 0: material

        spriteData

      else
        return null

    @circleSpriteGeometry = new ComputedField =>
      return unless palette = LOI.palette()

      # Construct the circle sprite.
      bitmap = """
        0011100
        0100010
        1000001
        1000001
        1000001
        0100010
        0011100
      """

      pixels = []

      for line, y in bitmap.split '\n'
        for char, x in line
          continue unless materialIndex = parseInt char

          pixels.push {x, y, materialIndex}

      layers: [{pixels}]
      palette: palette

    @circleSpriteData = new ComputedField =>
      return unless spriteData = @circleSpriteGeometry()
      return unless radius = @options.radius()

      if @editLight()
        normal = @options.lightDirection().clone().negate()

      else
        normal = @currentNormal()

      return unless normal

      position =
        x: normal.x * radius
        y: -normal.y * radius

      spriteData.layers[0].origin =
        x: position.x - 3
        y: position.y - 3

      bounds =
        x: position.x - 3
        y: position.y - 3
        width: 7
        height: 7

      bounds.left = bounds.x
      bounds.top = bounds.y
      bounds.right = bounds.left + bounds.width - 1
      bounds.bottom = bounds.top + bounds.height - 1

      spriteData.bounds = bounds

      if @editLight()
        circleColor = ramp: 1, shade: 8

      else
        circleColor = ramp: 0, shade: 8

      spriteData.materials =
        1: circleColor

      spriteData

  onCreated: ->
    super arguments...

    sphereSprite = new LOI.Assets.Engine.Sprite
      spriteData: @sphereSpriteData
      lightDirection: @options.lightDirection
      visualizeNormals: @options.visualizeNormals

    circleSprite = new LOI.Assets.Engine.Sprite
      spriteData: @circleSpriteData

    normalPicker = new @constructor.NormalPicker
      editor: => @

    @pixelCanvas new LOI.Assets.Components.PixelCanvas
      cameraInput: false
      grid: false
      cursor: false
      initialCameraScale: @options.initialCameraScale
      lightDirection: @options.lightDirection
      drawComponents: => [
        sphereSprite
        circleSprite
      ]
      activeTool: => normalPicker

    @angleSnapInput = new @constructor.AngleSnap @angleSnap

  setNormal: (normal) ->
    if normal
      @currentNormal new THREE.Vector3 normal.x, normal.y, normal.z

    else
      @currentNormal new THREE.Vector3 0, 0, 1

  canvasCoordinateToNormal: (coordinate, angleSnap) ->
    radius = @options.radius()

    # We reverse the y coordinate because normal is in right-handed 3D space.
    x = coordinate.x
    y = -coordinate.y
    z = Math.sqrt(Math.pow(radius, 2) - Math.pow(x, 2) - Math.pow(y, 2))

    normal = new THREE.Vector3(x, y, z).normalize()

    if angleSnap
      @constructor.snapNormalToAngle normal, angleSnap

    else
      normal

  @snapNormalToAngle: (normal, angleSnapDegrees) ->
    backward = new THREE.Vector3 0, 0, 1
    up = new THREE.Vector3 0, 1, 0

    # Find the angle from the center.
    angleSnap = THREE.Math.degToRad angleSnapDegrees
    snapToAngle = (angle) -> angle = Math.round(angle / angleSnap) * angleSnap

    verticalAngle = snapToAngle normal.angleTo backward
    horizontalAngle = snapToAngle Math.atan2 normal.y, normal.x

    rotationAxis = up.transformDirection new THREE.Matrix4().makeRotationZ horizontalAngle
    rotationQuaternion = new THREE.Quaternion().setFromAxisAngle rotationAxis, verticalAngle

    backward.transformDirection new THREE.Matrix4().makeRotationFromQuaternion rotationQuaternion

  editLightActiveClass: ->
    'active' if @editLight()

  events: ->
    super(arguments...).concat
      'click .edit-light-button': @onClickEditLightButton

  onClickEditLightButton: (event) ->
    @editLight not @editLight()

  # Components

  class @AngleSnap extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.Components.ShadingSphere.AngleSnap'

    constructor: (@angleSnap) ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    options: ->
      for angle in [0, 22.5, 30, 45, 90]
        name: if angle then "#{angle}°" else "None"
        value: angle

    load: ->
      @angleSnap()

    save: (value) ->
      @angleSnap parseFloat value
