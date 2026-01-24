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
    @_tutorialPixelArtLineWidth?.destroy()

  things: ->
    things = []

    elementsOfArtActive = LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.active()
    jaggiesActive = LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies.active()
    simplificationActive = LM.PixelArtFundamentals.Fundamentals.Goals.Simplification.active()
    
    @_tutorialLine ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.ElementsOfArt.Line
    things.push @_tutorialLine if elementsOfArtActive
    
    if @_tutorialLine.completed()
      @_tutorialShape ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.ElementsOfArt.Shape
      things.push @_tutorialShape if elementsOfArtActive

      @_tutorialPixelArtLines ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines
      things.push @_tutorialPixelArtLines if jaggiesActive
      
    if @_tutorialPixelArtLines?.completed()
      @_tutorialPixelArtDiagonals ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals
      things.push @_tutorialPixelArtDiagonals if jaggiesActive
    
      @_tutorialPixelArtCurves ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves
      things.push @_tutorialPixelArtCurves if jaggiesActive
      
      @_tutorialPixelArtLineWidth ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth
      things.push @_tutorialPixelArtLineWidth if jaggiesActive
    
    if @_tutorialShape?.completed()
      @_tutorialSimplification ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.Simplification
      things.push @_tutorialSimplification if simplificationActive
      
    things
