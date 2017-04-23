LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Intercom extends LOI.Adventure.Scene
  @id: -> 'Retronator.HQ.Items.Intercom.Scene'
  @timelineId: -> PAA.TimelineIds.RealLife
  @location: -> [
    Retronator.HQ.Cafe
    Retronator.HQ.Coworking
    Retronator.HQ.Store
    Retronator.HQ.Bookshelves
    Retronator.HQ.GalleryEast
    Retronator.HQ.GalleryWest
    Retronator.HQ.ArtStudio
    Retronator.HQ.LandsOfIllusions
  ]

  @initialize()

  things: ->
    HQ.Items.Intercom
