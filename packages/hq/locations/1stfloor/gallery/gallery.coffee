LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Gallery extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Gallery'
  @url: -> 'retronator/gallery'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
    'retronator_hq/actors/elevatorbutton.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ gallery"
  @shortName: -> "gallery"
  @description: ->
    "
      You enter a gallery with huge pixel art pieces hanged on the walls. One day you might be even able to look at them.
      There are doors leading north into the restroom as well as an elevator to the west.
    "
  
  @initialize()

  constructor: ->
    super

    HQ.Locations.Elevator.setupElevatorExit
      location: @
      floor: 1

  things: ->
    [HQ.Actors.ElevatorButton.id()]

  exits: ->
    exits = @elevatorExits()
    exits[Vocabulary.Keys.Directions.North] = HQ.Locations.Restroom.id()
    exits[Vocabulary.Keys.Directions.East] = HQ.Locations.Reception.id()
    exits[Vocabulary.Keys.Directions.Northeast] = HQ.Locations.Lobby.id()
    exits

  onScriptsLoaded: ->
    # Elevator button
    HQ.Actors.ElevatorButton.setupButton
      location: @
      floor: 1
