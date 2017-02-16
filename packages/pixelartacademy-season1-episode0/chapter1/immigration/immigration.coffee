LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1

class C1.Immigration extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration'

  @scenes: -> [
    @Concourse
  ]

  active: ->
    # We need to be explicit with booleans since undefined means we're not yet ready to determine our state.
    startFinished = C1.Start.finished()
    return unless startFinished?

    return false unless startFinished

    super

  @initialize()
