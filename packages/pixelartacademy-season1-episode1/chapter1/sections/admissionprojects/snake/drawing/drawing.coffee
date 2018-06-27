LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.AdmissionProjects.Snake.Drawing extends LOI.Adventure.Section
  # started: boolean if player has started this admission project
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionProjects.Snake.Drawing'

  @scenes: -> [
    @Coworking
  ]

  @initialize()

  @started: ->
    @requireFinishedSections C1.AdmissionProjects.Snake.Intro
    
  @finished: ->
    # Note: Make sure not to return undefined.
    @Coworking.Listener.Script.state('AdmissionProjectCompleted') is true
