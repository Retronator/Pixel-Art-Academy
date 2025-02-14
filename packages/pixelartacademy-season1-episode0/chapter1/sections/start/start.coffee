LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

class C1.Start extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Start'

  @scenes: -> [
    @Terrace
  ]

  @initialize()

  @started: -> true

  @finished: ->
    return unless LOI.adventure.gameState()

    # Intro section is over when the player has left the terrace. Make sure we don't return undefined though.
    @state('leftTerrace') is true
