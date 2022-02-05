AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum
AC = Artificial.Control

class AR.Pages.Chemistry.Materials.Shaders extends AM.Component
  @ShaderClasses:
    UniversalMaterial: "Universal material (Lands of Illusions)"
    PhysicalMaterial: "Physical material (three.js)"

  @Environments:
    "Procedural": 'Procedural'
    "Procedural (fully indirect)": 'ProceduralIndirect'
    "Ruckenkreuz": 'https://pixelartacademy.s3.amazonaws.com/environments/29p3mfSbZ6sYPSyag.hdr'
    "Derelict overpass": 'https://pixelartacademy.s3.amazonaws.com/environments/3Fst5HC7827ZPfsuc.hdr'
    "Kiara afternoon": 'https://pixelartacademy.s3.amazonaws.com/environments/5boAaN5hC5YAdDeSh.hdr'
    "Herkulessaulen": 'https://pixelartacademy.s3.amazonaws.com/environments/agvSadg5PZnXHbvjE.hdr'
    "Noon grass": 'https://pixelartacademy.s3.amazonaws.com/environments/ANbJH3snXXXoRvHPc.hdr'
    "Studio small": 'https://pixelartacademy.s3.amazonaws.com/environments/CjJNkzyrGPX9JaoaS.hdr'
    "Abandoned slipway": 'https://pixelartacademy.s3.amazonaws.com/environments/DZyHKSC9PG2HFtxbz.hdr'
    "Cayley interior": 'https://pixelartacademy.s3.amazonaws.com/environments/GW2QxG6qwHPjNnPoc.hdr'
    "Symmetrical garden": 'https://pixelartacademy.s3.amazonaws.com/environments/JdSuPj9FaWNRko8Hf.hdr'
    "Fondi crocette": 'https://pixelartacademy.s3.amazonaws.com/environments/juoHfNbnQ6Z4swZcr.hdr'
    "Quarry": 'https://pixelartacademy.s3.amazonaws.com/environments/kpviteyfvwQGBJfqJ.hdr'
    "Kloppenheim": 'https://pixelartacademy.s3.amazonaws.com/environments/MEgdDhiKgAGqvy8uw.hdr'

  @ProceduralSkySettings:
    "Derelict overpass":
      sunInclinationDegrees: 21
      sunAzimuthDegrees: 36
      sunFactor: 20
      skyFactor: 0.0013
    "Fondi crocette":
      sunInclinationDegrees: 28
      sunAzimuthDegrees: 347
      sunFactor: 20
      skyFactor: 0.0025
    "Kiara afternoon":
      sunInclinationDegrees: 37
      sunAzimuthDegrees: 42
      sunFactor: 12
      skyFactor: 0.0013
    "Kloppenheim":
      sunInclinationDegrees: 17
      sunAzimuthDegrees: 36
      sunFactor: 3
      skyFactor: 0.001
    "Noon grass":
      sunInclinationDegrees: 86
      sunAzimuthDegrees: 289
      sunFactor: 10
      skyFactor: 0.0013
    "Quarry":
      sunInclinationDegrees: 10
      sunAzimuthDegrees: 36
      sunFactor: 10
      skyFactor: 0.0016
    "Symmetrical garden":
      sunInclinationDegrees: 60
      sunAzimuthDegrees: 250
      sunFactor: 10
      skyFactor: 0.0016

  @ToneMappings:
    Linear: THREE.LinearToneMapping
    Reinhard: THREE.ReinhardToneMapping
    Cineon: THREE.CineonToneMapping
    "ACES Filmic": THREE.ACESFilmicToneMapping

  @initializeDataComponent()

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @app = @ancestorComponent Retronator.App
    @app.addComponent @

    # Environment settings
    @environmentName = new ReactiveField @constructor.Environments.Procedural
    @environmentUrl = new ComputedField => @constructor.Environments[@environmentName()]

    @sunInclinationDegrees = new ReactiveField 90
    @sunAzimuthDegrees = new ReactiveField 0
    @sunFactor = new ReactiveField 20
    @skyFactor = new ReactiveField 1.3e-3

    # Set procedural sky settings to match the environment.
    @autorun (computation) =>
      return if @environmentIsProcedural()
      return unless settings = @constructor.ProceduralSkySettings[@environmentName()]

      @sunInclinationDegrees settings.sunInclinationDegrees
      @sunAzimuthDegrees settings.sunAzimuthDegrees
      @sunFactor settings.sunFactor
      @skyFactor settings.skyFactor

    @sunPosition = new ComputedField =>
      sunInclination = AR.Degrees Math.round @sunInclinationDegrees()
      sunAzimuth = AR.Degrees Math.round @sunAzimuthDegrees()
      horizontalOffset = Math.cos sunInclination
      new THREE.Vector3 horizontalOffset * Math.cos(sunAzimuth), Math.sin(sunInclination), horizontalOffset * Math.sin(sunAzimuth)

    # Material settings
    @materialId = new ReactiveField AR.Chemistry.Materials.Compounds.Cellulose.id()
    @materialClass = new ComputedField =>
      AR.Chemistry.Materials.getClassForId @materialId()

    @subsurfaceHeterogeneity = new ReactiveField 1
    @hue = new ReactiveField 0
    @shade = new ReactiveField 8

    @shaderClass = new ReactiveField @constructor.ShaderClasses.UniversalMaterial

    # Rendering settings
    @toneMappingName = new ReactiveField 'Reinhard'
    @exposureValue = new ReactiveField 0

  environmentIsProcedural: ->
    environmentUrl = @environmentUrl()
    environmentUrl in ['Procedural', 'ProceduralIndirect']

  onRendered: ->
    super arguments...

    @$('.render-area').append @renderer.domElement

  colorPreviewStyle: ->
    return unless palette = LOI.palette()
    backgroundColor: palette.color(@hue(), @shade()).getStyle()

  events: ->
    super(arguments...).concat
      'mousemove .render-area canvas': @onMouseMoveRenderAreaCanvas

  onMouseMoveRenderAreaCanvas: (event) ->

  class @Environment extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.Environment'

    constructor: ->
      super arguments...

      @propertyName = 'environmentName'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = for name of AR.Pages.Chemistry.Materials.Shaders.Environments
        value: name
        name: name

      _.sortBy options, 'name'

  class @SunInclination extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.SunInclination'

    constructor: ->
      super arguments...

      @propertyName = 'sunInclinationDegrees'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: -90
        max: 270
        step: 1

  class @SunAzimuth extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.SunAzimuth'

    constructor: ->
      super arguments...

      @propertyName = 'sunAzimuthDegrees'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 360
        step: 1

  class @SunFactor extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.SunFactor'

    constructor: ->
      super arguments...

      @propertyName = 'sunFactor'
      @type = AM.DataInputComponent.Types.Number
      @customAttributes =
        min: 0
        step: 1

  class @SkyFactor extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.SkyFactor'

    constructor: ->
      super arguments...

      @propertyName = 'skyFactor'
      @type = AM.DataInputComponent.Types.Number
      @customAttributes =
        min: 0
        step: 0.0001

  class @MaterialId extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.MaterialId'

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

  class @SubsurfaceHeterogeneity extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.SubsurfaceHeterogeneity'

    constructor: ->
      super arguments...

      @propertyName = 'subsurfaceHeterogeneity'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 1
        step: 0.1

  class @Hue extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.Hue'

    constructor: ->
      super arguments...

      @propertyName = 'hue'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 15

  class @Shade extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.Shade'

    constructor: ->
      super arguments...

      @propertyName = 'shade'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 1
        max: 8

  class @ShaderClass extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.ShaderClass'

    constructor: ->
      super arguments...

      @propertyName = 'shaderClass'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      for shaderClass, shaderName of AR.Pages.Chemistry.Materials.Shaders.ShaderClasses
        value: shaderName
        name: shaderName

  class @ToneMapping extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.ToneMapping'

    constructor: ->
      super arguments...

      @propertyName = 'toneMappingName'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      for name of AR.Pages.Chemistry.Materials.Shaders.ToneMappings
        name: name
        value: name

  class @ExposureValue extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders.ExposureValue'

    constructor: ->
      super arguments...

      @propertyName = 'exposureValue'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: -20
        max: 20
        step: 0.5
