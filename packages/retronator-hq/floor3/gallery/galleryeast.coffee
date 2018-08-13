LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryEast extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.GalleryEast'
  @url: -> 'retronator/gallery/east'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Retronator Gallery east wing"
  @shortName: -> "gallery east"
  @description: ->
    "
      The east wing of the gallery opens up with an atrium that is shared with the art studio one floor above.
      More artworks line the walls, with tables in the middle holding interactive installations.
    "
  
  @initialize()

  things: -> [
    HQ.Actors.Corinne
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": HQ.GalleryWest
