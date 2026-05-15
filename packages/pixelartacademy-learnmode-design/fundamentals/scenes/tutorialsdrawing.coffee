LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.TutorialsDrawing extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.TutorialsDrawing'

  @location: -> PAA.Practice.Tutorials.Drawing

  @initialize()
  
  destroy: ->
    super arguments...
  
    @_archive?.destroy()
    @_tutorialShapeLanguage?.destroy()

  things: ->
    things = []
    
    if LM.Design.Fundamentals.Goals.ShapeLanguage.addedAndAvailable()
      if LM.Design.Fundamentals.Goals.ShapeLanguage.active()
        location = things
  
      else
        @_archive ?= Tracker.nonreactive => new PAA.PixelPad.Apps.Drawing.Portfolio.Archive
        
        # Reset previously added things.
        @_archive.things = []
        
        # Place tutorials to the archive.
        things.push @_archive
        location = @_archive.things
      
      @_tutorialShapeLanguage ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.Design.ShapeLanguage
      location.push @_tutorialShapeLanguage
    
    things
