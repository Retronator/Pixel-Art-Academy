LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryWest extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.GalleryWest'
  @url: -> 'retronator/gallery/west'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Retronator Gallery west wing"
  @shortName: -> "gallery"
  @description: ->
    "
      You enter a gallery with huge pixel art pieces hanged on the walls. This is the permanent collection of
      artworks made by Matej 'Retro' Jan. One day you'll be able to look at them, but they're not coded into the game yet.
      The hall continues to the east wing of the gallery. Stairs continue up to the art studio.
    "
  
  @meshId: -> 'Retronator.HQ.GalleryWest'
  @illustrationHeight: -> 200

  @initialize()

  constructor: ->
    super

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: 3

  things: -> [
    @elevatorButton
  ]

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: 3
    ,
      "#{Vocabulary.Keys.Directions.East}": HQ.GalleryEast
      "#{Vocabulary.Keys.Directions.Up}": HQ.ArtStudio
      "#{Vocabulary.Keys.Directions.Down}": HQ.Store
