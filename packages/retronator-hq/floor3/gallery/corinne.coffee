LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryEast.Corinne extends HQ.Actors.Corinne
  @translations: ->
    galleryEastDescriptiveName: "![Corinne](talk to Corinne) Colgan. She is sitting behind the curator's desk."

  @initialize()

  descriptiveName: -> @translations.galleryEastDescriptiveName
