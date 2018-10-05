LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Mixer extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer'

  @scenes: -> [
    @Intercom
    @Store
    @GalleryWest
    @ArtStudio
    @Coworking
  ]

  @initialize()

  @started: ->
    # Mixer starts after the character completes the Yearbook task.
    C1.Goals.StudyGroup.Yearbook.completedConditions() is true

  @finished: ->
    # TODO: Mixer section is over when the character has joined a study group.
    false
