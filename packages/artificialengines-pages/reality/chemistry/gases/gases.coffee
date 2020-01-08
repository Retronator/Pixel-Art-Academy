AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Gases extends AM.Component
  @Properties:
    Pressure: 'Pressure'
    Volume: 'Volume'
    Temperature: 'Temperature'
    AmountOfSubstance: 'AmountOfSubstance'

  @PropertyFieldNames = {}
  @PropertyFieldNames[property] = _.lowerFirst property for property of @Properties

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

  class @Pressure extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Gases.Pressure'

    constructor: ->
      super arguments...

      @propertyName = 'pressure'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 200
        step: 1

    load: ->
      super(arguments...) / 1e3

    save: (value) ->
      @parentComponent.setProperty AR.Pages.Chemistry.Gases.Properties.Pressure, value * 1e3

  class @Volume extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Gases.Volume'

    constructor: ->
      super arguments...

      @propertyName = 'volume'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 2
        step: 0.01

    save: (value) ->
      @parentComponent.setProperty AR.Pages.Chemistry.Gases.Properties.Volume, value

  class @Temperature extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Gases.Temperature'

    constructor: ->
      super arguments...

      @propertyName = 'temperature'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 500
        step: 1

    save: (value) ->
      @parentComponent.setProperty AR.Pages.Chemistry.Gases.Properties.Temperature, value

  class @AmountOfSubstance extends @DataInputComponent
    @register 'Artificial.Reality.Pages.Chemistry.Gases.AmountOfSubstance'

    constructor: ->
      super arguments...

      @propertyName = 'amountOfSubstance'
      @type = AM.DataInputComponent.Types.Range
      @customAttributes =
        min: 0
        max: 100
        step: 1

    save: (value) ->
      @parentComponent.setProperty AR.Pages.Chemistry.Gases.Properties.AmountOfSubstance, value

  class @Property extends @DataInputComponent
    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    options: ->
      names =
        Pressure: 'Pressure'
        Volume: 'Volume'
        Temperature: 'Temperature'
        AmountOfSubstance: 'Amount of substance'

      {value, name} for value, name of names

  class @XAxisProperty extends @Property
    @register 'Artificial.Reality.Pages.Chemistry.Gases.XAxisProperty'

    constructor: ->
      super arguments...

      @propertyName = 'xAxisProperty'

  class @YAxisProperty extends @Property
    @register 'Artificial.Reality.Pages.Chemistry.Gases.YAxisProperty'

    constructor: ->
      super arguments...

      @propertyName = 'yAxisProperty'
