LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Pinball = PAA.Pixeltosh.Programs.Pinball
Chess = PAA.Pixeltosh.Programs.Chess

class LM.PixelArtFundamentals.Fundamentals.Workbench extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Workbench'

  @location: -> PAA.Practice.Project.Workbench

  @initialize()

  destroy: ->
    super arguments...

    @_pinball?.destroy()

  things: ->
    things = []
    
    if LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.addedAndAvailable()
      # Pinball project appears after Pinball Creation Kit was run for the first time.
      openPinballMachineTask = PAA.Learning.Task.getAdventureInstanceForId LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.OpenPinballMachine.id()
      pinballProjectEnabled = openPinballMachineTask.completed()
      activePinballProjectId = Pinball.Project.state 'activeProjectId'
  
      if pinballProjectEnabled and activePinballProjectId
        if @_pinball?.projectId isnt activePinballProjectId
          @_pinball?.destroy()
          @_pinball = Tracker.nonreactive => new Pinball.Project activePinballProjectId
  
        things.push @_pinball
        
    if LM.PixelArtFundamentals.Fundamentals.Goals.Chess.addedAndAvailable() and Chess.state 'ownedPieceTypeCounts'
      if activeChess2DProjectId = Chess.Project.TwoDimensional.state 'activeProjectId'
        if @_chess2D?.projectId isnt activeChess2DProjectId
          @_chess2D?.destroy()
          @_chess2D = Tracker.nonreactive => new Chess.Project.TwoDimensional activeChess2DProjectId
        
        things.push @_chess2D

    things
