LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.TutorialsDrawing extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.TutorialsDrawing'

  @location: -> PAA.Practice.Tutorials.Drawing

  @initialize()
  
  destroy: ->
    super arguments...
  
    @_tutorialLine?.destroy()
    @_tutorialJaggies?.destroy()
    @_tutorialPixelArtDiagonals?.destroy()
    @_tutorialPixelArtCurves?.destroy()

  things: ->
    things = []

    @_tutorialLine ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.ElementsOfArt.Line
    things.push @_tutorialLine
    
    if @_tutorialLine.completed()
      @_tutorialPixelArtLines ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines
      things.push @_tutorialPixelArtLines
      
    if @_tutorialPixelArtLines?.completed()
      @_tutorialPixelArtDiagonals ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals
      things.push @_tutorialPixelArtDiagonals
    
      @_tutorialPixelArtCurves ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves
      things.push @_tutorialPixelArtCurves
      
    things
