LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Locations.Studio.Hallway extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Studio.Hallway'
  @url: -> 'retronator/studio/hallway'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
    'retronator_hq/actors/elevatorbutton.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Studio hallway"
  @shortName: -> "hallway"
  @description: ->
    "
      You're in a small vestibule hallway that connects the kitchen to the north, painting studio in the northeast,
      elevator in the west, as well as the apartment restroom eastward and bedroom to the south.
    "
  
  @initialize()

  constructor: ->
    super

    HQ.Locations.Elevator.setupElevatorExit
      location: @
      floor: 4

  things: ->
    [HQ.Actors.ElevatorButton.id()]

  exits: ->
    exits = @elevatorExits()
    exits[Vocabulary.Keys.Directions.North] = HQ.Locations.Studio.Kitchen.id()
    exits[Vocabulary.Keys.Directions.Northeast] = HQ.Locations.Studio.id()
    exits[Vocabulary.Keys.Directions.East] = HQ.Locations.Studio.Bathroom.id()
    exits[Vocabulary.Keys.Directions.South] = HQ.Locations.Studio.Bedroom.id()
    exits

  onScriptsLoaded: ->
    # Elevator button
    HQ.Actors.ElevatorButton.setupButton
      location: @
      floor: 4
