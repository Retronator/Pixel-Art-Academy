LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Workbench extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Workbench'

  @location: -> PAA.Practice.Project.Workbench

  @initialize()

  destroy: ->
    super arguments...

    @_pinball?.destroy()

  things: ->
    things = []
    
    pinballPlayTask = PAA.Learning.Task.getAdventureInstanceForId LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.Play
    pinballProjectEnabled = pinballPlayTask.completed()
    activePinballProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'

    if pinballProjectEnabled and activePinballProjectId
      @_pinball?.destroy()
      @_pinball = new PAA.Pixeltosh.Programs.Pinball.Project activePinballProjectId

      things.push @_pinball

    things
