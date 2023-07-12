AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

ray = new THREE.Ray
intersection = new THREE.Vector3

class AR.Pages.Optics.Sky extends AM.Component
  @initializeDataComponent()

  @Methods:
    Nishita: 'Nishita'
    NishitaRGB: 'NishitaRGB'
    ScratchapixelRGB: 'ScratchapixelRGB'
    Formulated: 'Formulated'
    FormulatedXYZ: 'FormulatedXYZ'
    FormulatedRGB: 'FormulatedRGB'

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @AirClass = AR.Chemistry.Materials.Mixtures.Air.DryMixture
    @SunEmissionSpectrum = AR.Chemistry.Materials.Mixtures.Stars.Sun.getEmissionSpectrumForTemperature 5778
    @earthRadius = 6371e3 # m
    atmosphereBoundsHeight = 50e3 #m
    @atmosphereBoundingSphere = new THREE.Sphere new THREE.Vector3(), @earthRadius + atmosphereBoundsHeight
    @earthBoundingSphere = new THREE.Sphere new THREE.Vector3(), @earthRadius - 1

    @method = new ReactiveField @constructor.Methods.FormulatedRGB

    @exposureValue = new ReactiveField 3
    @integrationStepSize = new ReactiveField 3

    @directLightEnabled = new ReactiveField true
    @rayleighScatteringEnabled = new ReactiveField true
    @mieScatteringEnabled = new ReactiveField true

    @sunAngleDegrees = new ReactiveField 30
    @hemispherePreviewHeight = new ReactiveField 0

  onRendered: ->
    super arguments...

    @canvas = @$('.preview')[0]
    @context = @canvas.getContext '2d'

    @offsetLeft = 60
    @offsetTop = 10

    @offsetLeftHemisphere = 470
    @offsetTopHemisphere = 30

    @offsetLeftSkydome = 60
    @offsetTopSkydome = 120

    @sidePreview =
      width: 361
      height: 50
      scale: 1000 # 1px = 1km
      data: new ReactiveField null

    @hemispherePreview =
      width: 181
      height: 181
      data: new ReactiveField null

    @skydomePreview =
      width: 361
      height: 91

    @previewDataCache = {}

    # Clear cache when parameters change.
    @autorun (computation) =>
      @method()
      @integrationStepSize()
      @directLightEnabled()
      @rayleighScatteringEnabled()
      @mieScatteringEnabled()

      Tracker.nonreactive =>
        for angle, previewData of @previewDataCache
          previewData null

    # Reactively prepare data for previews.
    @autorun (computation) =>
      sunAngleDegrees = Math.round @sunAngleDegrees()

      # Try to load data from cache. First make sure we have the field for it.
      Tracker.nonreactive => @previewDataCache[sunAngleDegrees] ?= new ReactiveField null

      previewData = @previewDataCache[sunAngleDegrees]()

      if previewData
        @sidePreview.data previewData.side
        @hemispherePreview.data previewData.hemisphere

      else
        Tracker.nonreactive =>
          @["compute#{@method()}"]()
          @previewDataCache[sunAngleDegrees]
            side: @sidePreview.data()
            hemisphere: @hemispherePreview.data()

    # Reactively draw all previews.
    @autorun (computation) =>
      @drawPreviews()

    @app = @ancestorComponentOfType Artificial.Base.App
    @app.addComponent @

  draw: (appTime) ->
    if @cycle
      @setSunAngleDegrees @sunAngleDegrees() + Math.min 1, appTime.elapsedAppTime * 10

  setSunAngleDegrees: (value) ->
    @sunAngleDegrees (value + 180) % 360 - 180

  _getLengthThroughAtmosphere: (position, direction) ->
    # Intersect atmosphere bounding sphere with the ray.
    ray.origin.copy position
    ray.direction.copy direction
    ray.intersectSphere @atmosphereBoundingSphere, intersection
    intersection.sub position
    intersection.length()

  _getLengthToEarth: (position, direction) ->
    # Intersect earth bounding sphere with the ray.
    ray.origin.copy position
    ray.direction.copy direction
    ray.intersectSphere @earthBoundingSphere, intersection
    intersection.sub position
    intersection.length()

  _intersectsEarth: (position, direction) ->
    # Intersect Earth bounding sphere with the ray.
    ray.origin.copy position
    ray.direction.copy direction
    ray.intersectsSphere @earthBoundingSphere

  _drawPoint: (context, x, y, radius) ->
    context.beginPath()
    context.arc x, y, radius, 0, Math.PI * 2
    context.fill()

  events: ->
    super(arguments...).concat
      'mousemove .preview': @mouseMovePreview
      'click .cycle-button': @onClickCycleButton

  mouseMovePreview: (event) ->
    @setSunAngleDegrees event.offsetX - @offsetLeft - 180
    # @hemispherePreviewHeight Math.max(0, @sidePreview.height - (event.offsetY - @offsetTop)) * @sidePreview.scale

  onClickCycleButton: (event) ->
    @cycle = not @cycle

  class @Method extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Optics.Sky.Method'

    constructor: ->
      super arguments...

      @propertyName = 'method'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      names =
        Nishita: 'Nishita et al.'
        NishitaRGB: 'Nishita et al. (RGB space)'
        ScratchapixelRGB: 'Scratchapixel (RGB space)'
        Formulated: 'Formulated'
        FormulatedXYZ: 'Formulated (XYZ space)'
        FormulatedRGB: 'Formulated (RGB space)'

      {value, name} for value, name of names

  class @ExposureValue extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Optics.Sky.ExposureValue'

    constructor: ->
      super arguments...

      @propertyName = 'exposureValue'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: -5
        max: 10
        step: 0.5

  class @IntegrationStepSize extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Optics.Sky.IntegrationStepSize'

    constructor: ->
      super arguments...

      @propertyName = 'integrationStepSize'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 1
        max: 50
        step: 1

  class @DirectLightEnabled extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Optics.Sky.DirectLightEnabled'

    constructor: ->
      super arguments...

      @propertyName = 'directLightEnabled'
      @type = AM.DataInputComponent.Types.Checkbox

  class @RayleighScatteringEnabled extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Optics.Sky.RayleighScatteringEnabled'

    constructor: ->
      super arguments...

      @propertyName = 'rayleighScatteringEnabled'
      @type = AM.DataInputComponent.Types.Checkbox

  class @MieScatteringEnabled extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Optics.Sky.MieScatteringEnabled'

    constructor: ->
      super arguments...

      @propertyName = 'mieScatteringEnabled'
      @type = AM.DataInputComponent.Types.Checkbox
