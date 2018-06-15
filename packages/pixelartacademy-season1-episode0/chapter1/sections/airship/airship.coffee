LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

class C1.Airship extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Airship'

  @scenes: -> [
    @Arrivals
    @Tower
    @Terminal
    @Dock
    @Cabin
  ]

  @initialize()

  @started: ->
    @requireFinishedSections C1.Immigration

  @finished: ->
    # Airship section is over together with chapter 1.
    C1.finished()
