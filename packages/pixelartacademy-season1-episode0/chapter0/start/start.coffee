LOI = LandsOfIllusions
C0 = PixelArtAcademy.Season1.Episode0.Chapter0

class C0.Start extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter0.Start'

  @scenes: -> [
    @Terrace
  ]

  active: ->
    not @finished()
