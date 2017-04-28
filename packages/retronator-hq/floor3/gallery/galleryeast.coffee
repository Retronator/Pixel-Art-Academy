LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryEast extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.EastGallery'
  @url: -> 'retronator/gallery/east'

  @version: -> '0.0.1'

  @fullName: -> "Retronator Gallery east wing"
  @shortName: -> "gallery east"
  @description: ->
    "
      The east wing of the gallery opens up with an atrium that is shared with the art studio one storey above.
      More artworks line the north wall, and a big collection of video games sits on the shelves in the south. Tables in
      the middle hold interactive installations.
    "
  
  @initialize()

  things: -> [
    PAA.Cast.Corinne
    PAA.Cast.Shelley
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": HQ.GalleryWest
