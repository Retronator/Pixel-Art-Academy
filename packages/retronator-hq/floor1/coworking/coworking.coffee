LOI = LandsOfIllusions
HQ = Retronator.HQ

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
      The passageway opens to a dimly-lit room with a cyberpunk hacker vibe.
      Tables fill the space, together with workstations for the permanent residents of the coworking space.
    "

  @listeners: ->
    super(arguments...).concat [
    ]

  @initialize()

  constructor: ->
    super arguments...

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: 1

  things: -> [
    @constructor.Reuben
    @elevatorButton
  ]

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: 1
    ,
      "#{Vocabulary.Keys.Directions.East}": HQ.Cafe
      "#{Vocabulary.Keys.Directions.Down}": HQ.Basement
