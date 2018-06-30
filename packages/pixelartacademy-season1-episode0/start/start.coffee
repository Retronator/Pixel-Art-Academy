LOI = LandsOfIllusions
PAA = PixelArtAcademy
E0 = PixelArtAcademy.Season1.Episode0
RS = Retropolis.Spaceport

class E0.Start extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Start'

  # We don't need any scenes (but we need to be explicit about it).
  @scenes: -> []

  @initialize()

  @started: -> true

  @finished: ->
    # Episode 0 needs to start automatically so we automatically end this
    # special dummy intro section (episodes require a trigger intro section).
    true
