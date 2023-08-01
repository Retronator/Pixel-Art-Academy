AEc = Artificial.Echo
LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Nodes.Location extends AEc.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Nodes.Location'
  @displayName: -> 'Location'

  @initialize()

  @outputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Press
  ]

  @parameters: ->
    locationClasses = _.filter LOI.Adventure.Thing.getClasses(), (thingClass) =>
      thingClass.prototype instanceof LOI.Adventure.Location

    options = for locationClass in locationClasses when locationClass.fullName()
      name: _.upperFirst locationClass.shortName()
      value: locationClass.id()

    options = _.sortBy options, 'value'
    
    [
      name: 'id'
      pattern: [String]
      options: options
      showValuesInDropdown: true
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.String
    ]

  constructor: ->
    super arguments...

    @value = new ComputedField =>
      return unless locationIds = @readParameter 'id'

      # Create an array if needed.
      locationIds = [locationIds] unless _.isArray locationIds

      # Location value is true if current location is the same as one of the id parameter values.
      currentLocationId = LOI.adventure.currentLocationId()

      currentLocationId in locationIds
    ,
      true
    
  destroy: ->
    super arguments...
    
    @value.stop()

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'
    
    @value
