AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AS.Pages.Color.Chromaticity extends AM.Component
  @LightSourceTypes:
    BlackBody: 'BlackBody'
    A: 'A'
    D: 'D'
    D65: 'D65'

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    LightTypes = @constructor.LightSourceTypes

    @lightSourceType = new ReactiveField LightTypes.BlackBody
    @temperature = new ReactiveField 5000 # K

    @lightSourceClass = new ComputedField =>
      switch @lightSourceType()
        when LightTypes.BlackBody then AR.Optics.LightSources.BlackBody
        when LightTypes.A then AR.Optics.LightSources.CIE.A.Formulated
        when LightTypes.D65 then AR.Optics.LightSources.CIE.D65

    @spectrumYAxis = new ComputedField =>
      switch @lightSourceType()
        when LightTypes.BlackBody, LightTypes.D65
          spacing: 10
          maxValue: 60

        when LightTypes.A
          spacing: 0.1
          maxValue: 1

    @lightSourceEmissionSpectrum = new ComputedField =>
      lightSourceClass = @lightSourceClass()

      switch @lightSourceType()
        # Temperature based
        when LightTypes.BlackBody
          lightSourceClass.getEmissionSpectrumForTemperature @temperature()

        # Fixed
        when LightTypes.D65, LightTypes.A
          lightSourceClass.getEmissionSpectrum()

    @correlatedColorTemperature = new ComputedField =>
      lightSourceClass = @lightSourceClass()
      _.propertyValue lightSourceClass, 'correlatedColorTemperature'

    @lightSourceXYZ = new ComputedField =>
      AS.Color.CIE1931.getXYZForSpectrum @lightSourceEmissionSpectrum()

    @lightSourceNormalizedXYZ = new ComputedField =>
      AS.Color.SRGB.getNormalizedXYZForXYZ @lightSourceXYZ()

    @lightSourceLinearRGB = new ComputedField =>
      AS.Color.SRGB.getLinearRGBForXYZ @lightSourceXYZ()

    @lightSourceRGB = new ComputedField =>
      rgb = AS.Color.SRGB.getRGBForLinearRGB @lightSourceLinearRGB()

      # Scale to 0–255 range.
      rgb[color] = _.clamp Math.round(rgb[color] * 255), 0, 255 for color in ['r', 'g', 'b']

      rgb

  lightPreviewStyle: ->
    rgb = @lightSourceRGB()

    backgroundColor: "rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})"

  xyzString: ->
    value = @lightSourceXYZ()

    @_formatTriplet value.x, value.y, value.z, 1

  normalizedXYZString: ->
    value = @lightSourceNormalizedXYZ()

    @_formatTriplet value.x, value.y, value.z, 4

  linearRGBString: ->
    value = @lightSourceLinearRGB()

    @_formatTriplet value.r, value.g, value.b

  rgbString: ->
    value = @lightSourceRGB()

    @_formatTriplet value.r, value.g, value.b, 0

  _formatTriplet: (a, b, c, digits = 2) ->
    "[#{a.toFixed digits}, #{b.toFixed digits}, #{c.toFixed digits}]"

  onRendered: ->
    super arguments...

    # Automatically update the spectrum graph.
    @autorun (computation) =>
      @drawSpectrum()

    @prepareSRGBimage()

    # Automatically update the chromaticity diagram.
    @autorun (computation) =>
      @drawChromaticityDiagram()

  _drawPoint: (context, x, y, radius) ->
    context.beginPath()
    context.arc x, y, radius, 0, Math.PI * 2
    context.fill()

  class @LightSourceType extends AM.DataInputComponent
    @register 'Artificial.Spectrum.Pages.Color.Chromaticity.LightSourceType'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super arguments

      @chromaticity = @ancestorComponentOfType AS.Pages.Color.Chromaticity

    options: ->
      names =
        BlackBody: 'Black body'
        A: 'CIE A (incandescent)'
        D: 'CIE D (daylight)'
        D65: 'CIE D65 (daylight, 6504 K)'

      {value, name} for value, name of names

    load: ->
      @chromaticity.lightSourceType()

    save: (value) ->
      @chromaticity.lightSourceType value

  class @Temperature extends AM.DataInputComponent
    @register 'Artificial.Spectrum.Pages.Color.Chromaticity.Temperature'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 10000

    onCreated: ->
      super arguments

      @chromaticity = @ancestorComponentOfType AS.Pages.Color.Chromaticity

    load: ->
      @chromaticity.temperature()

    save: (value) ->
      @chromaticity.temperature value
