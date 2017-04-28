LOI = LandsOfIllusions
PAA = PixelArtAcademy
E0 = PixelArtAcademy.Season1.Episode0
RS = Retropolis.Spaceport

class E0.Start extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Start'

  @finished: ->
    # Episode 0 is automatically started.
    true

  # We don't need any scenes (but we need to be explicit about it).
  @scenes: -> []

  @initialize()
