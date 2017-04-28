LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Residence.Hallway extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Residence.Hallway'
  @url: -> 'retronator/residence/hallway'

  @version: -> '0.0.1'

  @fullName: -> "residence hallway"
  @shortName: -> "hallway"
  @description: ->
    "
      You enter Retronator residence where Retro and guests go to recover after a hard day of work.
      There is nothing to explore for now, but be back in the future.
    "
  
  @initialize()

  constructor: ->
    super

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
      "#{Vocabulary.Keys.Directions.Up}": HQ.Residence.UpstairsHallway
      "#{Vocabulary.Keys.Directions.Down}": HQ.ArtStudio
