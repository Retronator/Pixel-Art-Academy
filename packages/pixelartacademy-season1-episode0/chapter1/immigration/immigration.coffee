LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1

class C1.Immigration extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration'

  @scenes: -> [
    @Terrace
  ]

  active: ->
    return unless C1.Start.finished()

    super
