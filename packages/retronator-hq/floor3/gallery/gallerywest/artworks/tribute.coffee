LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryWest.Artworks.Tribute extends HQ.Gallery.ArtworksGroup
  @id: -> 'Retronator.HQ.GalleryWest.Artworks.Tribute'
  @fullName: -> "Tribute"
  @description: ->
    "
      It's a big isometric illustration with dozens of popular culture references.
    "

  @illustration: ->
    mesh: 'retronator/hq/floor3/gallery/gallery'
    object: 'Tribute'

  @initialize()
