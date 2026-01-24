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
    return unless LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.active()
    
    things = []
    
    # Pinball project appears after Pinball Creation Kit was run for the first time.
    openPinballMachineTask = PAA.Learning.Task.getAdventureInstanceForId LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.OpenPinballMachine.id()
    pinballProjectEnabled = openPinballMachineTask.completed()
    activePinballProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'

    if pinballProjectEnabled and activePinballProjectId
      @_pinball?.destroy()
      @_pinball = new PAA.Pixeltosh.Programs.Pinball.Project activePinballProjectId

      things.push @_pinball

    things
