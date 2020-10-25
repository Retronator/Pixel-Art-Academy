LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryWest.Artworks.ZXCosmopolis extends HQ.Gallery.ArtworksGroup
  @id: -> 'Retronator.HQ.GalleryWest.Artworks.ZXCosmopolis'
  @url: -> 'retronator/zxcosmopolis'
  @fullName: -> "ZX Cosmopolis"
  @descriptiveName: -> "![ZX Cosmopolis](look at ZX Cosmopolis)."
  @description: ->
    "
      It's a fan pixel art piece based on the movie Speed Racer.
    "

  @illustration: ->
    mesh: 'retronator/hq/floor3/gallery/gallery'
    object: 'ZX Cosmopolis'

  @initialize()

  constructor: ->
    super arguments...

    @artworksInfo =
      zxCosmopolis:
        artistInfo: @artistsInfo.matejJan
        title: 'ZX Cosmopolis'
        caption: 'Based on Cosmopolis Skyline Concept by George Hull'
