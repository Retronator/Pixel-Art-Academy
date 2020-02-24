AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Optics.Sky extends AM.Component
  @initializeDataComponent()

  @Methods:
    Nishita: 'Nishita'
    Formulated: 'Formulated'

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @AirClass = AR.Chemistry.Materials.Mixtures.Air.DryMixture
    @SpectrumClass = AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5
    @D65EmissionSpectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()
    @earthRadius = 6371e3 # m

    @method = new ReactiveField @constructor.Methods.Formulated

    @exposureValue = new ReactiveField 1
    @integrationStepSize = new ReactiveField 10

    @directLightEnabled = new ReactiveField true
    @rayleighScatteringEnabled = new ReactiveField false
    @mieScatteringEnabled = new ReactiveField false

    @sunAngleDegrees = new ReactiveField 90
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

    @app = @ancestorComponent Retronator.App
    @app.addComponent @

  draw: (appTime) ->
    if @cycle
      @setSunAngleDegrees @sunAngleDegrees() + Math.min 1, appTime.elapsedAppTime * 10

  setSunAngleDegrees: (value) ->
    @sunAngleDegrees (value + 180) % 360 - 180

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
        Formulated: 'Formulated'

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
