AEc = Artificial.Echo
LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Nodes.LocationChange extends AEc.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Nodes.LocationChange'
  @displayName: -> 'Location Change'

  @initialize()

  @outputs: -> [
    name: 'trigger'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Trigger
  ]

  @parameters: ->
    locationClasses = _.filter LOI.Adventure.Thing.getClasses(), (thingClass) =>
      thingClass.prototype instanceof LOI.Adventure.Location

    options = for locationClass in locationClasses when locationClass.fullName()
      name: _.upperFirst locationClass.shortName()
      value: locationClass.id()

    options = _.sortBy options, 'value'
    
    [
      name: 'from'
      pattern: [String]
      options: options
      showValuesInDropdown: true
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.String
    ,
      name: 'to'
      pattern: [String]
      options: options
      showValuesInDropdown: true
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: AEc.ValueTypes.String
    ]

  constructor: ->
    super arguments...

    @trigger = new ReactiveField false
    
    @locationId = null

    @autorun (computation) =>
      return unless fromLocationIds = @readParameter 'from'
      return unless toLocationIds = @readParameter 'to'

      # Create arrays if needed.
      fromLocationIds = [fromLocationIds] unless _.isArray fromLocationIds
      toLocationIds = [toLocationIds] unless _.isArray toLocationIds

      newLocationId = LOI.adventure.currentLocationId()
      toLocation = newLocationId in toLocationIds

      fromLocation = @locationId in fromLocationIds

      # When we're going between locations in from and to sets, set the value to true for one frame.
      if fromLocation and toLocation
        @trigger true
        
        Meteor.setTimeout =>
          @trigger false

      @locationId = newLocationId

  getReactiveValue: (output) ->
    return super arguments... unless output is 'trigger'
    
    @trigger
