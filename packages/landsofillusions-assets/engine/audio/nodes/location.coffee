LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Location extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Location'
  @nodeName: -> 'Location'

  @initialize()

  @outputs: -> [
    name: 'value'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ]

  @parameters: ->
    locationClasses = _.filter LOI.Adventure.Thing.getClasses(), (thingClass) =>
      thingClass.prototype instanceof LOI.Adventure.Location

    locationIds = (locationClass.id() for locationClass in locationClasses when locationClass.fullName())

    [
      name: 'id'
      pattern: String
      options: locationIds
      type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
    ]

  getReactiveValue: (output) ->
    return unless output is 'value'
    
    =>
      # Location value is true if current location is the same as the id parameter.
      currentLocationId = @audio.options.world().options.adventure.currentLocationId()
      locationId = @readParameter 'id'

      locationId is currentLocationId
