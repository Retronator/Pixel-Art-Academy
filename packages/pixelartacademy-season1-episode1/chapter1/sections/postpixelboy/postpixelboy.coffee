LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.PostPixelBoy extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelBoy'

  @scenes: -> [
    @DrawingChallenges
    @Store
    @PixelArt
    @GalleryEast
  ]

  @initialize()

  @started: ->
    # This applies after the PixelBoy section.
    @requireFinishedSections C1.PixelBoy

  # This scene is present forever.
  @finished: -> false
