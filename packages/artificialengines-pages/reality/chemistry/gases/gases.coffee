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

  @Scales:
    Pressure:
      range: 200e3
      step: 1
      multiplier: 1e3
      name: 'Pressure'
      unit: 'kPa'
    Volume:
      range: 2
      step: 0.1
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

  @initializeDataComponent()

  constructor: (@app) ->
    super arguments...

  onCreated: ->
    super arguments...

    @gasId = new ReactiveField AR.Chemistry.Materials.Elements.Nitrogen.id()

    @gasClass = new ComputedField =>
      AR.Chemistry.Materials.getClassForId @gasId()
      
    @pressure = new ReactiveField AR.StandardTemperatureAndPressure.Pressure
    @volume = new ReactiveField 1
    @temperature = new ReactiveField AR.StandardTemperatureAndPressure.Temperature
    @amountOfSubstance = new ReactiveField()

    @recalculateProperty @constructor.Properties.AmountOfSubstance

    @xAxisProperty = new ReactiveField @constructor.Properties.Pressure
    @yAxisProperty = new ReactiveField @constructor.Properties.Volume

  onRendered: ->
    super arguments...

    # Automatically update the properties graph.
    @autorun (computation) => @drawPropertiesGraph()

  pressureString: ->
    (@pressure() / 1e3).toFixed 2

  volumeString: ->
    @volume().toFixed 2

  temperatureString: ->
    @temperature().toFixed 2

  amountOfSubstanceString: ->
    @amountOfSubstance().toFixed 2

  refractiveIndex: ->
    gasClass = @gasClass()

    refractiveIndexSpectrum = gasClass.getRefractiveIndexSpectrumForState @getGasState()
    refractiveIndexSpectrum 500e-9

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
      for property, scale of AR.Pages.Chemistry.Gases.Scales
        value: property
        name: scale.name

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
