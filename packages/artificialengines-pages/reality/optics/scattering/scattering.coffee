AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Optics.Scattering extends AM.Component
  @initializeDataComponent()

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @materialId = new ReactiveField AR.Chemistry.Materials.Mixtures.Air.DryMixture.id()

    @materialClass = new ComputedField =>
      AR.Chemistry.Materials.getClassForId @materialId()

    @densityFactor = new ReactiveField 10

  onRendered: ->
    super arguments...

    @canvas = @$('.preview')[0]
    @context = @canvas.getContext '2d'

    @offsetLeft = 10
    @offsetTop = 10

    @preview =
      width: 200
      height: 151
      scale: 1000 # 1px = 1km

    @volume =
      left: 25
      top: 50
      width: 150
      height: 51

    @volume.right = @volume.left + @volume.width - 1
    @volume.bottom = @volume.top + @volume.height - 1

    @SpectrumClass = AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5
    @D65EmissionSpectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()

    # Automatically update Rayleigh scattering preview.
    @autorun (computation) =>
      @materialClass()
      @densityFactor()

      Tracker.nonreactive =>
        # @drawRayleighScatteringCells()
        # @drawRayleighScatteringSingle()
        @prepareRayleighScatteringCellsAnimated()
        # @prepareRayleighScatteringCellsInscatteringAnimated()
        # @prepareRayleighScatteringSingleAnimated()

    @app = @ancestorComponentOfType Artificial.Base.App
    @app.addComponent @

  draw: (appTime) ->
    @drawRayleighScatteringCellsAnimated()
    # @drawRayleighScatteringCellsInscatteringAnimated()
    # @drawRayleighScatteringSingleAnimated()

  _drawPoint: (context, x, y, radius) ->
    context.beginPath()
    context.arc x, y, radius, 0, Math.PI * 2
    context.fill()

  _startDraw: ->
    @context.setTransform 1, 0, 0, 1, 0, 0
    @context.clearRect 0, 0, @canvas.width, @canvas.height
    @context.translate @offsetLeft + 0.5, @offsetTop + 0.5

    # Clear preview to black.
    @context.fillStyle = 'black'
    @context.fillRect 0, 0, @preview.width, @preview.height

  _drawPreviewElements: ->
    # Draw the @volume.
    @context.strokeStyle = 'gainsboro'
    @context.lineWidth = 1
    @context.globalAlpha = 0.2
    @context.strokeRect @volume.left - 1, @volume.top - 1, @volume.width + 1, @volume.height + 1
    @context.globalAlpha = 1

    # Draw the border.
    @context.strokeStyle = 'ghostwhite'
    @context.strokeRect 0, 0, @preview.width, @preview.height

    # Draw scale.
    @context.fillStyle = 'ghostwhite'
    @context.font = '12px "Source Sans Pro", sans-serif'

    @context.textAlign = 'center'
    @context.fillText "distance (km)", 90, 190

    @context.beginPath()

    for x in [0..@preview.width] by 50
      # Write the number on the axis.
      xKilometers = Math.round x * @preview.scale / 1e3

      @context.textAlign = 'center'
      @context.fillText xKilometers, x, @preview.height + 16

  class @MaterialId extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Optics.Scattering.MaterialId'

    constructor: ->
      super arguments...

      @propertyName = 'materialId'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = for materialClass in AR.Chemistry.Materials.getClasses() when materialClass.prototype instanceof AR.Chemistry.Materials.Gas
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

  class @DensityFactor extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Optics.Scattering.DensityFactor'

    constructor: ->
      super arguments...

      @propertyName = 'densityFactor'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 10
        step: 0.1
