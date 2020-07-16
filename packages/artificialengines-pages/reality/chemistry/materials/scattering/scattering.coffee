AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum
AC = Artificial.Control

class AR.Pages.Chemistry.Materials.Scattering extends AM.Component
  @initializeDataComponent()

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    AC.Keyboard.initialize()

    @app = @ancestorComponent Retronator.App
    @app.addComponent @

    # Prepare material selection.
    @materialId = new ReactiveField AR.Chemistry.Materials.Elements.Gold.id()
    @materialClass = new ComputedField =>
      AR.Chemistry.Materials.getClassForId @materialId()

    # Prepare surface properties.
    @surfaceImageUrl = new ReactiveField ''
    @surfaceUpscaleFactor = new ReactiveField 4

    # Prepare calculation properties.
    @raysCountPower = new ReactiveField 13
    @raysCount = new ComputedField => 2 ** @raysCountPower()
    @scatteringEventsCount = new ReactiveField 6

    @lightRayDirection = new ReactiveField new THREE.Vector3(0, 1, 0).normalize()
    @beamWidth = new ReactiveField 1

    # Prepare rendering properties.
    @schematicView = new ReactiveField false
    @exposureValue = new ReactiveField -8

    @_initialize()

  onRendered: ->
    super arguments...

    @$('.render-area').append @renderer.domElement

  events: ->
    super(arguments...).concat
      'mousemove .render-area canvas': @onMouseMoveRenderAreaCanvas

  onMouseMoveRenderAreaCanvas: (event) ->
    return unless surfaceHelpers = @surfaceHelpers()
    keyboardState = AC.Keyboard.getState()

    if keyboardState.isKeyDown AC.Keys.m
      mousePosition = new THREE.Vector3 event.offsetX, event.offsetY, 0
      direction = surfaceHelpers.rayTarget.clone().sub(mousePosition).normalize()

      @lightRayDirection direction

    else
      surfaceCanvas = @surfaceCanvas()
      size = @size()

      surfaceCanvas.context.fillStyle = 'white'

      if keyboardState.isKeyDown AC.Keys[1]
        brushWidth = 1

      else if keyboardState.isKeyDown AC.Keys[2]
        brushWidth = 3

      else if keyboardState.isKeyDown AC.Keys[3]
        brushWidth = 5

      else if keyboardState.isKeyDown AC.Keys[4]
        brushWidth = 7

      if keyboardState.isKeyDown AC.Keys.e
        surfaceCanvas.context.fillStyle = 'black'

      if brushWidth
        x = Math.floor(event.offsetX / size.width * surfaceCanvas.width) + 0.5
        y = Math.floor(event.offsetY / size.height * surfaceCanvas.height) + 0.5
        h = brushWidth / 2

        surfaceCanvas.context.fillRect x - h, y - h, brushWidth, brushWidth

        @surfaceCanvas surfaceCanvas

  class @MaterialId extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Scattering.MaterialId'

    constructor: ->
      super arguments...

      @propertyName = 'materialId'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = for materialClass in AR.Chemistry.Materials.getClasses()
        if displayName = materialClass.displayName()
          if formula = materialClass.formula()
            name = "#{displayName} (#{formula})"

          else
            name = displayName

        else
          name = materialClass.id()

        value: materialClass.id()
        name: name

      _.sortBy options, 'name'

    save: ->
      super arguments...

      @parentComponent.$('select').blur()

  class @SurfaceImageUrl extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Scattering.SurfaceImageUrl'

    constructor: ->
      super arguments...

      @propertyName = 'surfaceImageUrl'
      @type = AM.DataInputComponent.Types.Text

  class @SurfaceUpscaleFactor extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Scattering.SurfaceUpscaleFactor'

    constructor: ->
      super arguments...

      @propertyName = 'surfaceUpscaleFactor'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 1
        max: 4
        step: 1

  class @RaysCountPower extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Scattering.RaysCountPower'

    constructor: ->
      super arguments...

      @propertyName = 'raysCountPower'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 1
        max: 13

  class @ScatteringEventsCount extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Scattering.ScatteringEventsCount'

    constructor: ->
      super arguments...

      @propertyName = 'scatteringEventsCount'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 13

  class @BeamWidth extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Scattering.BeamWidth'

    constructor: ->
      super arguments...

      @propertyName = 'beamWidth'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 1
        max: 100
        step: 1

  class @SchematicView extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Scattering.SchematicView'

    constructor: ->
      super arguments...

      @propertyName = 'schematicView'
      @type = AM.DataInputComponent.Types.Checkbox

  class @ExposureValue extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Scattering.ExposureValue'

    constructor: ->
      super arguments...

      @propertyName = 'exposureValue'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: -10
        max: 10
        step: 0.1
