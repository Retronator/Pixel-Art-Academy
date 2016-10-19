LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Adventure.Parser.Vocabulary

Actor = LOI.Adventure.Actor
Action = LOI.Adventure.Actor.Abilities.Action
Talking = LOI.Adventure.Actor.Abilities.Talking

class HQ.Locations.Lobby.Elevator extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Lobby.Elevator'
  @url: -> 'retronator/lobby/elevator'

  @fullName: -> "Lobby floor elevator"

  @shortName: -> "elevator"

  @description: ->
    "
      You are in the elevator on the lobby floor of Retronator HQ. The number pad on the side lets you travel to other
      floors.
    "

  @initialize()

  constructor: ->
    super

    @addExit Vocabulary.Keys.Directions.Out, HQ.Locations.Lobby.id()

    pad = new Actor
      name: "number pad"
      
    @addActor pad

    pad.addAbility Action,
      verb: "press"
      action: =>
        LOI.Adventure.goToLocation HQ.Locations.Store.Elevator.id()
        