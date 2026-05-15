LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.TutorialsDrawing extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.TutorialsDrawing'

  @location: -> PAA.Practice.Tutorials.Drawing

  @initialize()
  
  destroy: ->
    super arguments...
  
    @_archive?.destroy()
    @_pixelArtFundamentals?.destroy()
    @_tutorialLine?.destroy()
    @_tutorialShape?.destroy()
    @_tutorialPixelArtLines?.destroy()
    @_tutorialPixelArtDiagonals?.destroy()
    @_tutorialPixelArtCurves?.destroy()
    @_tutorialPixelArtLineWidth?.destroy()
    @_tutorialSimplification?.destroy()
    @_tutorialSize?.destroy()

  things: ->
    things = []

    if LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.activeAndAvailable()
      @_tutorialLine ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.ElementsOfArt.Line
      things.push @_tutorialLine
    
      if @_tutorialLine.completed()
        @_tutorialShape ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.ElementsOfArt.Shape
        things.push @_tutorialShape
    
    # Prepare portfolio folders.
    @_pixelArtFundamentals ?= Tracker.nonreactive => new @constructor.PixelArtFundamentals
    @_archive ?= Tracker.nonreactive => new PAA.PixelPad.Apps.Drawing.Portfolio.Archive
    
    # Reset previously added things.  
    @_pixelArtFundamentals.things = []
    @_archive.things = []

    if LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies.addedAndAvailable()
      if LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies.active()
        location = things
        
      else
        location = @_pixelArtFundamentals.things
        
      @_tutorialPixelArtLines ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines
      location.push @_tutorialPixelArtLines
      
      if @_tutorialPixelArtLines?.completed()
        @_tutorialPixelArtDiagonals ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals
        location.push @_tutorialPixelArtDiagonals
      
        @_tutorialPixelArtCurves ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves
        location.push @_tutorialPixelArtCurves
        
        @_tutorialPixelArtLineWidth ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth
        location.push @_tutorialPixelArtLineWidth
    
    if LM.PixelArtFundamentals.Fundamentals.Goals.Size.addedAndAvailable()
      if LM.PixelArtFundamentals.Fundamentals.Goals.Size.active()
        location = things
      
      else
        location = @_pixelArtFundamentals.things
        
      @_tutorialSize ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtFundamentals.Size
      location.push @_tutorialSize
    
    # Add pixel art fundamentals folder if needed.
    @_archive.things.push @_pixelArtFundamentals if @_pixelArtFundamentals.things.length
    
    if LM.PixelArtFundamentals.Fundamentals.Goals.Simplification.addedAndAvailable()
      if LM.PixelArtFundamentals.Fundamentals.Goals.Simplification.active()
        location = things
      
      else
        location = @_archive.things
      
      @_tutorialSimplification ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.Simplification
      location.push @_tutorialSimplification
    
    # Add archive folders if needed.
    things.push @_archive if @_archive.things.length
    
    things
  
  class @PixelArtFundamentals extends PAA.PixelPad.Apps.Drawing.Portfolio.Folder
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.TutorialsDrawing.PixelArtFundamentals'
    
    @displayName: -> "Pixel art fundamentals"
    
    @initialize()
