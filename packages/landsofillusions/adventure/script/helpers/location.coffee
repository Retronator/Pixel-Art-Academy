LOI = LandsOfIllusions

class LOI.Adventure.Script.Helpers extends LOI.Adventure.Script.Helpers
  addThingToLocation: (options) ->
    locationState = @adventure.getLocationState options.location

    locationState.things[options.thing.id()] = options.state or {}
    @adventure.gameState.updated()

  removeThingFromLocation: (options) ->
    locationState = @adventure.getLocationState options.location
    thing = locationState.things[options.thing.id()]
    
    delete locationState.things[options.thing.id()]
    @adventure.gameState.updated()
    
    thing

  moveThingBetweenLocations: (options) ->
    thing = @removeThingFromLocation
      location: options.sourceLocation
      thing: options.thing

    @addThingToLocation
      location: options.destinationLocation
      thing: options.thing
      state: thing

    @adventure.gameState.updated()
