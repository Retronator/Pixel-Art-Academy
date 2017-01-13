LOI = LandsOfIllusions

class LOI.Adventure.Script.Helpers extends LOI.Adventure.Script.Helpers
  addThingToLocation: (options) ->
    locationState = LOI.adventure.getLocationState options.location

    locationState.things[options.thing.id()] = options.state or {}
    LOI.adventure.gameState.updated()

  removeThingFromLocation: (options) ->
    locationState = LOI.adventure.getLocationState options.location
    thing = locationState.things[options.thing.id()]
    
    delete locationState.things[options.thing.id()]
    LOI.adventure.gameState.updated()
    
    thing

  moveThingBetweenLocations: (options) ->
    thing = @removeThingFromLocation
      location: options.sourceLocation
      thing: options.thing

    @addThingToLocation
      location: options.destinationLocation
      thing: options.thing
      state: thing

    LOI.adventure.gameState.updated()
