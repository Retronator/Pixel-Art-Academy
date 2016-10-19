LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Adventure.Parser.Vocabulary

Actor = LOI.Adventure.Actor
Action = LOI.Adventure.Actor.Abilities.Action
Talking = LOI.Adventure.Actor.Abilities.Talking

class HQ.Locations.Store extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Store'
  @url: -> 'retronator/store'

  @fullName: -> "Retronator store"

  @shortName: -> "store"

  @description: ->
    "
      You are in the store inside Retronator HQ. Shelves are filled with different bundles of the game Pixel Art Academy.
    "

  @initialize()

  constructor: ->
    super

    @addExit Vocabulary.Keys.Directions.In, HQ.Locations.Store.Elevator.id()

