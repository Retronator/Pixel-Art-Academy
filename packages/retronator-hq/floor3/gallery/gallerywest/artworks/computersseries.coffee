LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryWest.Artworks.ComputersSeries extends HQ.Gallery.ArtworksGroup
  @id: -> 'Retronator.HQ.GalleryWest.Artworks.ComputersSeries'
  @url: -> 'retronator/computers'
  @fullName: -> "Computers series"
  @descriptiveName: -> "![Computers series](look at the Computers series)."
  @description: ->
    "
      A set of pixel/vexel artworks of old and new computers.
    "

  @illustration: ->
    mesh: 'retronator/hq/floor3/gallery/gallery'
    object: 'Computers series'

  @initialize()

  constructor: ->
    super arguments...

    @artworksInfo =
      pixelSpectrum:
        artistInfo: @artistsInfo.matejJan
        title: 'Pixel Spectrum'
      pixel64:
        artistInfo: @artistsInfo.matejJan
        title: 'Pixel 64'
      pixelberryPi:
        artistInfo: @artistsInfo.matejJan
        title: 'Pixelberry Pi'
