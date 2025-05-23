LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Mixer extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer'

  @scenes: -> [
    @Intercom
    @Store
    @GalleryWest
    @GalleryWest.Student
    @ArtStudio
    @Coworking
    @Ace
    @Ty
    @Saanvi
    @Mae
    @Lisa
    @Jaxx
  ]

  @initialize()

  @started: ->
    # Mixer starts after the character completes the Yearbook task.
    C1.Goals.StudyGroup.Yearbook.completedConditions() is true

  @finished: ->
    # Mixer is over when the player has finished the Gallery West script.
    C1.Mixer.GalleryWest.scriptState('MixerEnd') is true
