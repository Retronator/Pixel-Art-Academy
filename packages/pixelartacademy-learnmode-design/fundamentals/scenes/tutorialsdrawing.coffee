LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.TutorialsDrawing extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.TutorialsDrawing'

  @location: -> PAA.Practice.Tutorials.Drawing

  @initialize()
  
  destroy: ->
    super arguments...
  
    @_tutorialShapeLanguage?.destroy()

  things: ->
    things = []
    
    if LM.Design.Fundamentals.Goals.ShapeLanguage.activeAndAvailable()
      @_tutorialShapeLanguage ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.Design.ShapeLanguage
      things.push @_tutorialShapeLanguage
    
    things
