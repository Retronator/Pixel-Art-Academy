LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryWest.Artworks.JulieSeries extends HQ.Gallery.ArtworksGroup
  @id: -> 'Retronator.HQ.GalleryWest.Artworks.JulieSeries'
  @url: -> 'retronator/julie'
  @fullName: -> "Julie series"
  @descriptiveName: -> "![Julie series](look at the Julie series)."
  @description: ->
    "
      A set of low-resolution paintings of nature, based on photographs by Julie Rolla.
    "

  @illustration: ->
    mesh: 'retronator/hq/floor3/gallery/gallery'
    object: 'Julie series'

  @initialize()

  constructor: ->
    super arguments...

    @artworksInfo =
      mountainLake:
        artistInfo: @artistsInfo.matejJan
        title: 'Mountain Lake'
        caption: 'Original photograph by Julie Rolla (Moraine Lake, Banff National Park, Alberta, Canada)'
      mountainPass:
        artistInfo: @artistsInfo.matejJan
        title: 'Mountain Pass'
        caption: 'Original photograph by Julie Rolla (Mirror Lake, Yosemite National Park, California, USA)'
      savanna:
        artistInfo: @artistsInfo.matejJan
        title: 'Savanna'
        caption: 'Original photograph by Julie Rolla (Thailand)'
