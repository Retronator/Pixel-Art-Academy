LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Coworking extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Coworking'
  @url: -> 'retronator/coworking'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Coworking space"
  @shortName: -> "coworking"
  @description: ->
    "
      The passageway opens to a dimly-lit room with a cyberpunk hacker vibe to it.
      Tables fill the space, together with workstations for the permanent residents of the coworking space.
    "

  @listeners: ->
    super.concat [
    ]

  @initialize()

  constructor: ->
    super

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: 1

  things: -> [
    HQ.Actors.Aeronaut
    @elevatorButton
  ]

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: 1
    ,
      "#{Vocabulary.Keys.Directions.East}": HQ.Cafe
      "#{Vocabulary.Keys.Directions.Down}": HQ.Basement
