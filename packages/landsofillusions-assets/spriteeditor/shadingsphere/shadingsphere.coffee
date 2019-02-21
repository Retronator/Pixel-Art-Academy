AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.ShadingSphere extends FM.View
  # angleSnap: setting to snap normals to certain angles
  # radius: how big to draw the sphere
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.ShadingSphere'
  @register @id()

  onCreated: ->
    super arguments...

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    @componentData = @interface.getComponentData @
    @angleSnap = @componentData.child('angleSnap').value
    @radius = @componentData.child('radius').value

    @editLight = new ReactiveField false
    @pixelCanvas = new ReactiveField null

    @lightDirectionHelper = new ComputedField =>
      @interface.getHelperForActiveFile LOI.Assets.SpriteEditor.Helpers.LightDirection

    @lightDirection = new ComputedField =>
      return unless lightDirectionHelper = @lightDirectionHelper()
      lightDirectionHelper()

    @visualizeNormals = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child('paintNormals').value

    @sphereSpriteGeometry = new ComputedField =>
      # Construct the sphere sprite.
      return unless radius = @radius()
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
      invertZ = @paintHelper.normal().z < 0

      pixels = []

      for x in [bounds.left..bounds.right]
        for y in [bounds.top..bounds.bottom]
          pixelCenter = new THREE.Vector2 x + 0.5, y + 0.5
          continue if pixelCenter.length() > radius

          normal = @canvasCoordinateToNormal pixelCenter, angleSnap
          normal.z *= -1 if invertZ

          pixels.push {x, y, normal, materialIndex}

      layers: [{pixels}]
      bounds: bounds

    @sphereSpriteData = new ComputedField =>
      return unless spriteData = @sphereSpriteGeometry()
      return unless loader = @interface.getLoaderForActiveFile()

      paletteId = loader.paletteId()
      paletteColor = @paintHelper.paletteColor()
      materialIndex = @paintHelper.materialIndex()

      if @visualizeNormals()
        # Just return the sprite without any extra color information.
        sphereSpriteData = spriteData

      else if paletteId and (paletteColor or materialIndex?)
        # Add palette information to sprite.
        sphereSpriteData = _.clone spriteData
        sphereSpriteData.palette = _id: paletteId

        if materialIndex?
          asset = loader.asset()
          material = asset.materials?[materialIndex]

        else
          material = paletteColor

        unless material?.ramp? and material?.shade?
          sphereSpriteData = null

        else
          sphereSpriteData.materials = 0: material

      unless sphereSpriteData
        sphereSpriteData = _.clone spriteData

        shades = for shade in [0..1] by 0.01
          r: shade, g: shade, b: shade

        sphereSpriteData.customPalette = ramps: [shades: shades]
        sphereSpriteData.materials = 0: ramp: 0, shade: 100

      sphereSpriteData

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
      return unless radius = @radius()

      if @editLight()
        normal = @lightDirection().clone().negate()

      else
        normal = @paintHelper.normal()

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
        if @paintHelper.normal().z < 0
          circleColor = ramp: 0, shade: 4

        else
          circleColor = ramp: 0, shade: 8

      spriteData.materials =
        1: circleColor

      spriteData

    sphereSprite = new LOI.Assets.Engine.Sprite
      spriteData: @sphereSpriteData
      visualizeNormals: @visualizeNormals

    circleSprite = new LOI.Assets.Engine.Sprite
      spriteData: @circleSpriteData

    normalPicker = new @constructor.NormalPicker
      editor: => @

    @pixelCanvas new LOI.Assets.Components.PixelCanvas
      cameraInput: false
      grid: false
      cursor: false
      lightDirection: @lightDirection
      drawComponents: => [
        sphereSprite
        circleSprite
      ]
      activeTool: => normalPicker

    @angleSnapInput = new @constructor.AngleSnap @angleSnap

  setNormal: (normal) ->
    @paintHelper.setNormal normal

  canvasCoordinateToNormal: (coordinate, angleSnap) ->
    radius = @radius()

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
    @register 'LandsOfIllusions.Assets.SpriteEditor.ShadingSphere.AngleSnap'

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
