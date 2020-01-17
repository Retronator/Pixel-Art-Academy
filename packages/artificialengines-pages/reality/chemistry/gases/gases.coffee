AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Gases extends AM.Component
  @Properties:
    Pressure: 'Pressure'
    Volume: 'Volume'
    Temperature: 'Temperature'
    AmountOfSubstance: 'AmountOfSubstance'

  @PropertyFieldNames: {}
  @PropertyFieldNames[property] = _.lowerFirst property for property of @Properties

  @SpectrumProperties:
    RefractiveIndex: 'RefractiveIndex'
    KingCorrectionFactor: 'KingCorrectionFactor'
    RayleighScatteringCrossSection: 'RayleighScatteringCrossSection'

  @SpectrumPropertyFieldNames: {}
  @SpectrumPropertyFieldNames[property] = _.lowerFirst property for property of @SpectrumProperties

  @Scales:
    Pressure:
      range: 200e3
      step: 1
      multiplier: 1e3
      name: 'Pressure'
      unit: 'kPa'
    Volume:
      range: 2
      step: 0.01
      name: 'Volume'
      unit: 'm³'
    Temperature:
      range: 500
      step: 1
      name: 'Temperature'
      unit: 'K'
    AmountOfSubstance:
      range: 100
      step: 1
      name: 'Amount of substance'
      unit: 'mol'
    RefractiveIndex:
      range: 0.0005
      subtract: 1
      multiplier: 0.001
      name: 'Refractive index - 1'
      unit: '10⁻³'
    KingCorrectionFactor:
      range: 0.2
      subtract: 1
      multiplier: 0.01
      name: 'King correction factor - 1'
      unit: '%'
    RayleighScatteringCrossSection:
      range: 5e-30
      multiplier: 1e-31
      name: 'Rayleigh scattering cross section'
      unit: '10⁻³¹ m²'

  @initializeDataComponent()

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @gasId = new ReactiveField AR.Chemistry.Materials.Compounds.WaterVapor.id()

    @gasClass = new ComputedField =>
      AR.Chemistry.Materials.getClassForId @gasId()
      
    @pressure = new ReactiveField 1e5
    @volume = new ReactiveField 1
    @temperature = new ReactiveField AR.Celsius 0
    @amountOfSubstance = new ReactiveField()

    # Every time gas changes, recalculate amount of substance.
    @autorun (computation) =>
      @gasId()
      Tracker.nonreactive => @recalculateProperty @constructor.Properties.AmountOfSubstance

    @xAxisProperty = new ReactiveField @constructor.Properties.Pressure
    @yAxisProperty = new ReactiveField @constructor.Properties.AmountOfSubstance

    @wavelength = new ReactiveField 500e-9

    @spectrumYAxisProperty = new ReactiveField @constructor.SpectrumProperties.RefractiveIndex

  onRendered: ->
    super arguments...

    # Automatically update the properties graph.
    @autorun (computation) => @drawPropertiesGraph()

    # Automatically update the spectrum graph.
    @autorun (computation) => @drawSpectrumGraph()

  pressureString: ->
    pressure = @pressure()
    return "N/A" unless pressure?

    (pressure / 1e3).toFixed 2

  volumeString: ->
    volume = @volume()
    return "N/A" unless volume?

    volume.toFixed 2

  temperatureString: ->
    temperature = @temperature()
    return "N/A" unless temperature?

    temperature.toFixed 2

  amountOfSubstanceString: ->
    amountOfSubstance = @amountOfSubstance()
    return "N/A" unless amountOfSubstance?

    amountOfSubstance.toFixed 2

  wavelengthNanometersString: ->
    Math.round @wavelength() * 1e9

  refractiveIndex: ->
    gasClass = @gasClass()
    wavelength = @wavelength()

    refractiveIndexSpectrum = gasClass.getRefractiveIndexSpectrumForState @getGasState()
    refractiveIndexSpectrum wavelength

  kingCorrectionFactor: ->
    gasClass = @gasClass()
    wavelength = @wavelength()

    return 1 unless kingCorrectionFactorSpectrum = gasClass.getKingCorrectionFactorSpectrum()

    kingCorrectionFactorSpectrum wavelength

  rayleighScatteringCrossSection: ->
    gasClass = @gasClass()
    wavelength = @wavelength()
    gasState = @getGasState()

    refractiveIndexSpectrum = gasClass.getRefractiveIndexSpectrumForState gasState
    refractiveIndex = refractiveIndexSpectrum wavelength

    kingCorrectionFactorSpectrum = gasClass.getKingCorrectionFactorSpectrum()
    kingCorrectionFactor = kingCorrectionFactorSpectrum? wavelength

    rayleighCrossSectionFunction = AR.Optics.Scattering.getRayleighCrossSectionFunction()
    rayleighCrossSectionFunction refractiveIndex, gasState.amountOfSubstance / gasState.volume * AR.AvogadroNumber, wavelength, kingCorrectionFactor

  getGasState: ->
    pressure: @pressure()
    temperature: @temperature()
    volume: @volume()
    amountOfSubstance: @amountOfSubstance()
    
  setProperty: (property, value) ->
    propertyFieldName = @constructor.PropertyFieldNames[property]
    @[propertyFieldName] value
    
    # See which other property to change to reflect the new value.
    yAxisProperty = @yAxisProperty()
    
    if yAxisProperty is property
      changeProperty = @xAxisProperty()
      
    else
      changeProperty = yAxisProperty
      
    @recalculateProperty changeProperty
      
  recalculateProperty: (property) ->
    gasClass = @gasClass()

    propertyFieldName = @constructor.PropertyFieldNames[property]
    @[propertyFieldName] gasClass["get#{property}ForState"] @getGasState()

  _drawPoint: (context, x, y, radius) ->
    context.beginPath()
    context.arc x, y, radius, 0, Math.PI * 2
    context.fill()

  events: ->
    super(arguments...).concat
      'mousemove .spectrum-graph': @mouseMoveSpectrumGraph

  mouseMoveSpectrumGraph: (event) ->
    @wavelength (event.offsetX + 380 - 70) * 1e-9

  class @GasId extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Gases.GasId'

    constructor: ->
      super arguments...

      @propertyName = 'gasId'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = for gasClass in AR.Chemistry.Materials.getClasses() when gasClass.prototype instanceof AR.Chemistry.Materials.Gas
        if displayName = gasClass.displayName()
          if formula = gasClass.formula()
            name = "#{displayName} (#{formula})"

          else
            name = displayName

        else
          name = gasClass.id()

        value: gasClass.id()
        name: name

      _.sortBy options, 'name'

  class @PropertyValue extends @DataInputComponent
    constructor: (@property) ->
      super arguments...

      @propertyName = AR.Pages.Chemistry.Gases.PropertyFieldNames[@property]
      @scale = AR.Pages.Chemistry.Gases.Scales[@property]
      @multiplier = @scale.multiplier or 1

      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: @scale.range / @multiplier
        step: @scale.step

    load: ->
      super(arguments...) / @multiplier

    save: (value) ->
      @parentComponent.setProperty @property, value * @multiplier

  class @Pressure extends @PropertyValue
    @register 'Artificial.Reality.Pages.Chemistry.Gases.Pressure'
    constructor: -> super AR.Pages.Chemistry.Gases.Properties.Pressure

  class @Volume extends @PropertyValue
    @register 'Artificial.Reality.Pages.Chemistry.Gases.Volume'
    constructor: -> super AR.Pages.Chemistry.Gases.Properties.Volume

  class @Temperature extends @PropertyValue
    @register 'Artificial.Reality.Pages.Chemistry.Gases.Temperature'
    constructor: -> super AR.Pages.Chemistry.Gases.Properties.Temperature

  class @AmountOfSubstance extends @PropertyValue
    @register 'Artificial.Reality.Pages.Chemistry.Gases.AmountOfSubstance'
    constructor: -> super AR.Pages.Chemistry.Gases.Properties.AmountOfSubstance

  class @PropertySelection extends @DataInputComponent
    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    options: ->
      for property of AR.Pages.Chemistry.Gases.Properties
        value: property
        name: AR.Pages.Chemistry.Gases.Scales[property].name

  class @XAxisProperty extends @PropertySelection
    @register 'Artificial.Reality.Pages.Chemistry.Gases.XAxisProperty'

    constructor: ->
      super arguments...

      @propertyName = 'xAxisProperty'

  class @YAxisProperty extends @PropertySelection
    @register 'Artificial.Reality.Pages.Chemistry.Gases.YAxisProperty'

    constructor: ->
      super arguments...

      @propertyName = 'yAxisProperty'

  class @SpectrumYAxisProperty extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Gases.SpectrumYAxisProperty'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select
      @propertyName = 'spectrumYAxisProperty'

    options: ->
      for property of AR.Pages.Chemistry.Gases.SpectrumProperties
        value: property
        name: AR.Pages.Chemistry.Gases.Scales[property].name
