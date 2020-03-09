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
    Sun: 'Sun'
    Iron: 'Iron'
    Gold: 'Gold'

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
        when LightTypes.D then AR.Optics.LightSources.CIE.D
        when LightTypes.D65 then AR.Optics.LightSources.CIE.D65
        when LightTypes.Sun then AR.Chemistry.Materials.Mixtures.Stars.Sun
        when LightTypes.Iron then AR.Chemistry.Materials.Elements.Iron
        when LightTypes.Gold then AR.Chemistry.Materials.Elements.Gold

    @spectrumYAxis = new ComputedField =>
      switch @lightSourceType()
        when LightTypes.BlackBody, LightTypes.D, LightTypes.D65, LightTypes.Sun, LightTypes.Iron, LightTypes.Gold
          spacing: 10
          maxValue: 60

        when LightTypes.A
          spacing: 0.1
          maxValue: 1

    @lightSourceEmissionSpectrum = new ComputedField =>
      lightSourceClass = @lightSourceClass()

      switch @lightSourceType()
        when LightTypes.BlackBody, LightTypes.Sun, LightTypes.Iron, LightTypes.Gold
          lightSourceClass.getEmissionSpectrumForTemperature @temperature()

        when LightTypes.D
          temperature = @temperature()
          return unless 4000 <= temperature <= 27000

          lightSourceClass.getEmissionSpectrumForCorrelatedColorTemperature temperature

        when LightTypes.D65, LightTypes.A
          lightSourceClass.getEmissionSpectrum()

    @correlatedColorTemperature = new ComputedField =>
      switch @lightSourceType()
        when LightTypes.D, LightTypes.Sun, LightTypes.Iron, LightTypes.Gold
          @temperature()

        else
          _.propertyValue @lightSourceClass(), 'correlatedColorTemperature'

    @lightSourceXYZ = new ComputedField =>
      return unless spectrum = @lightSourceEmissionSpectrum()
      AS.Color.CIE1931.getXYZForSpectrum spectrum

    @lightSourceNormalizedXYZ = new ComputedField =>
      return unless xyz = @lightSourceXYZ()
      AS.Color.SRGB.getNormalizedXYZForXYZ xyz

    @lightSourceLinearRGB = new ComputedField =>
      return unless xyz = @lightSourceXYZ()
      AS.Color.SRGB.getLinearRGBForXYZ xyz

    @lightSourceRGB = new ComputedField =>
      return unless linearRGB = @lightSourceLinearRGB()
      rgb = AS.Color.SRGB.getRGBForLinearRGB linearRGB

      # Scale to 0–255 range.
      rgb[color] = _.clamp Math.round(rgb[color] * 255), 0, 255 for color in ['r', 'g', 'b']

      rgb

    @lightSourceChromaticityRGB = new ComputedField =>
      return unless xyz = @lightSourceXYZ()

      linearRGB = AS.Color.SRGB.getLinearRGBForXYZ xyz

      # Normalize to highest component.
      maxComponent = _.max [linearRGB.r, linearRGB.g, linearRGB.b]
      linearRGB[component] = linearRGB[component] / maxComponent for component in ['r', 'g', 'b'] if maxComponent

      rgb = AS.Color.SRGB.getRGBForLinearRGB linearRGB

      # Scale to 0–255 range.
      rgb[component] = _.clamp Math.round(rgb[component] * 255), 0, 255 for component in ['r', 'g', 'b']

      rgb

  onRendered: ->
    super arguments...

    # Automatically update the spectrum graph.
    @autorun (computation) => @drawSpectrum()

    # Automatically update the chromaticity diagram.
    @prepareSRGBimage()
    @autorun (computation) => @drawChromaticityDiagram()

  lightPreviewStyle: ->
    return unless rgb = @lightSourceRGB()

    backgroundColor: "rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})"

  chromaticityPreviewStyle: ->
    return unless rgb = @lightSourceChromaticityRGB()

    backgroundColor: "rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})"

  xyzString: ->
    return "not defined" unless value = @lightSourceXYZ()

    @_formatTriplet value.x, value.y, value.z, 1

  normalizedXYZString: ->
    return "not defined" unless value = @lightSourceNormalizedXYZ()

    @_formatTriplet value.x, value.y, value.z, 4

  linearRGBString: ->
    return "not defined" unless value = @lightSourceLinearRGB()

    @_formatTriplet value.r, value.g, value.b

  rgbString: ->
    return "not defined" unless value = @lightSourceRGB()

    @_formatTriplet value.r, value.g, value.b, 0

  _formatTriplet: (a, b, c, digits = 2) ->
    "[#{a.toFixed digits}, #{b.toFixed digits}, #{c.toFixed digits}]"

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
        Sun: 'Sun (hydrogen-helium gas mixture)'
        Iron: 'Iron'
        Gold: 'Gold'

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
