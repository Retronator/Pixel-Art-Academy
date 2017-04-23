LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.ArtStudio'
  @url: -> 'retronator/artstudio'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ art studio"
  @shortName: -> "art studio"
  @description: ->
    "
      Fourth floor of the headquarters holds a painting studio.
      Easels are spread throughout the space together with a drafting table by the wall.
      Stairs continue up into the residence part of the HQ, but it requires keycard access.
    "
  
  @initialize()

  constructor: ->
    super

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: 4

  things: -> [
    @elevatorButton
  ]

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: 4
    ,
      "#{Vocabulary.Keys.Directions.Down}": HQ.GalleryWest
      "#{Vocabulary.Keys.Directions.Up}": HQ.Residence.Hallway
