LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.PostPixelPad extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelPad'

  @scenes: -> [
    @DrawingChallenges
    @Store
    @PixelArt
    @CopyReference.GalleryEast
    @CopyReference.GalleryWest
    @CopyReference.Store
    @CopyReference.Bookshelves
  ]

  @initialize()

  @started: ->
    # This applies after the PixelPad section.
    @requireFinishedSections C1.PixelPad

  # This scene is present forever.
  @finished: -> false
