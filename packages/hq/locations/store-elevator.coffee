LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Adventure.Parser.Vocabulary

Actor = LOI.Adventure.Actor
Action = LOI.Adventure.Actor.Abilities.Action
Talking = LOI.Adventure.Actor.Abilities.Talking

class HQ.Locations.Store.Elevator extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Store.Elevator'
  @url: -> 'retronator/store/elevator'

  @fullName: -> "Store floor elevator"

  @shortName: -> "elevator"

  @description: ->
    "
      You are in the elevator on the store floor of Retronator HQ. The number pad on the side lets you travel to other
      floors.
    "

  @initialize()

  constructor: ->
    super

    @addExit Vocabulary.Keys.Directions.Out, HQ.Locations.Store.id()

    pad = new Actor
      name: "number pad"

    @addActor pad

    pad.addAbility Action,
      verb: "press"
      action: =>
        LOI.Adventure.goToLocation HQ.Locations.Lobby.Elevator.id()
