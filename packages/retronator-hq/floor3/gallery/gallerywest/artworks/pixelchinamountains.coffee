LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryWest.Artworks.PixelChinaMountains extends HQ.Gallery.ArtworksGroup
  @id: -> 'Retronator.HQ.GalleryWest.Artworks.PixelChinaMountains'
  @url: -> 'retronator/china'
  @fullName: -> "Pixel China Mountains"
  @descriptiveName: -> "![Pixel China Mountains](look at Pixel China Mountains)."
  @description: ->
    "
      It's a fan pixel art piece based on Marta Nael's digital painting China Mountains.
    "

  @illustration: ->
    mesh: 'retronator/hq/floor3/gallery/gallery'
    object: 'Pixel China Mountains'

  @initialize()

  constructor: ->
    super arguments...

    @artworksInfo =
      tribute:
        artistInfo: @artistsInfo.matejJan
        title: 'Pixel China Mountains'
        caption: 'Based on China Mountains by Marta Nael'
