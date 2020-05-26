LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Residence.Hallway extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Residence.Hallway'
  @url: -> 'retronator/residence/hallway'
  @region: -> HQ.Residence

  @version: -> '0.0.1'

  @fullName: -> "residence hallway"
  @shortName: -> "hallway"
  @description: ->
    "
      You enter Retronator residence where Retro and guests go to recover after a hard day of work.
      Exploring the rooms seem a bit intrusive, but the hallway leads to an open space in the east.
    "
  
  @initialize()

  constructor: ->
    super arguments...

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: 5

  things: -> [
    @elevatorButton
  ]

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: 5
    ,
      "#{Vocabulary.Keys.Directions.East}": HQ.Residence.Kitchen
      "#{Vocabulary.Keys.Directions.Down}": HQ.ArtStudio
