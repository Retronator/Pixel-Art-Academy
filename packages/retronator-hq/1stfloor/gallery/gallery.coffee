LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Gallery extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Gallery'
  @url: -> 'retronator/gallery'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
    'retronator-hq/actors/elevatorbutton.script'
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

    HQ.Elevator.setupElevatorExit
      location: @
      floor: 1

  things: ->
    [HQ.Actors.ElevatorButton.id()]

  exits: ->
    exits = @elevatorExits()
    exits[Vocabulary.Keys.Directions.North] = HQ.Restroom.id()
    exits[Vocabulary.Keys.Directions.East] = HQ.Cafe.id()
    exits[Vocabulary.Keys.Directions.Northeast] = HQ.Lobby.id()
    exits

  onScriptsLoaded: ->
    # Elevator button
    HQ.Actors.ElevatorButton.setupButton
      location: @
      floor: 1
