AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.ShadingSphere extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.ShadingSphere'

  constructor: (@options) ->
    super

    @currentNormal = new ReactiveField new THREE.Vector3 0, 0, 1

    @editLight = new ReactiveField false

    @pixelCanvas = new ReactiveField null

    @sphereSpriteGeometry = new ComputedField =>
      # Construct the sphere sprite.
      return unless radius = @options.radius()

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

          normal = @canvasCoordinateToNormal pixelCenter

          pixels.push {x, y, normal, materialIndex}

      layers: [pixels: pixels]
      bounds: bounds

    @sphereSpriteData = new ComputedField =>
      return unless spriteData = @sphereSpriteGeometry()

      # Add palette information to sprite.
      palette = @options.palette()
      return unless paletteId = palette.options.paletteId()

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
    super

    sphereSprite = new LOI.Assets.Engine.Sprite
      spriteData: @sphereSpriteData
      lightDirection: @options.lightDirection

    circleSprite = new LOI.Assets.Engine.Sprite
      spriteData: @circleSpriteData

    normalPicker = new @constructor.NormalPicker
      editor: => @

    @pixelCanvas new LOI.Assets.Components.PixelCanvas
      cameraInput: false
      grid: false
      cursor: false
      initialCameraScale: @options.initialCameraScale
      drawComponents: => [
        sphereSprite
        circleSprite
      ]
      activeTool: => normalPicker

  setNormal: (normal) ->
    @currentNormal normal

  canvasCoordinateToNormal: (coordinate) ->
    radius = @options.radius()

    # We reverse the y coordinate because normal is in right-handed 3D space.
    x = coordinate.x
    y = -coordinate.y
    z = Math.sqrt(Math.pow(radius, 2) - Math.pow(x, 2) - Math.pow(y, 2))

    new THREE.Vector3(x, y, z).normalize()

  editLightActiveClass: ->
    'active' if @editLight()

  events: ->
    super.concat
      'click .edit-light-button': @onClickEditLightButton

  onClickEditLightButton: (event) ->
    @editLight not @editLight()
