LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Location extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Location'
  @nodeName: -> 'Location'

  @initialize()

  @outputs: -> [
    name: 'value'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    valueType: LOI.Assets.Engine.Audio.ValueTypes.Press
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
      type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
      valueType: LOI.Assets.Engine.Audio.ValueTypes.String
    ]

  constructor: ->
    super arguments...

    @value = new ComputedField =>
      return unless locationIds = @readParameter 'id'

      # Create an array if needed.
      locationIds = [locationIds] unless _.isArray locationIds

      # Location value is true if current location is the same as one of the id parameter values.
      currentLocationId = @audio.world().options.adventure.currentLocationId()

      currentLocationId in locationIds

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'
    
    @value
