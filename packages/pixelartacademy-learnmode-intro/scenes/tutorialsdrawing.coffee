LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.TutorialsDrawing extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.TutorialsDrawing'

  @location: -> PAA.Practice.Tutorials.Drawing

  @initialize()
  
  destroy: ->
    super arguments...
  
    @_archive?.destroy()
    @_pixelArtTools?.destroy()
    @_tutorialBasics?.destroy()
    @_tutorialColors?.destroy()
    @_tutorialHelpers?.destroy()

  things: ->
    things = []

    if LM.Intro.Tutorial.Goals.PixelArtSoftware.addedAndAvailable()
      if LM.Intro.Tutorial.Goals.PixelArtSoftware.active()
        location = things
      
      else
        # Prepare portfolio folders.
        @_pixelArtTools ?= Tracker.nonreactive => new @constructor.PixelArtTools
        @_archive ?= Tracker.nonreactive => new PAA.PixelPad.Apps.Drawing.Portfolio.Archive
        
        # Reset previously added things.
        @_pixelArtTools.things = []
        @_archive.things = [@_pixelArtTools]
        
        # Place tutorials to the archive.
        things.push @_archive
        location = @_pixelArtTools.things
      
      # Player needs the Desktop editor selected for the tutorial to display.
      if PAA.PixelPad.Apps.Drawing.state('editorId') is PAA.PixelPad.Apps.Drawing.Editor.Desktop.id()
        @_tutorialBasics ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtTools.Basics
        location.push @_tutorialBasics
  
        if @_tutorialBasics.completed()
          @_tutorialColors ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtTools.Colors
          @_tutorialHelpers ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtTools.Helpers
  
          location.push @_tutorialColors, @_tutorialHelpers

    things
    
  class @PixelArtTools extends PAA.PixelPad.Apps.Drawing.Portfolio.GroupFolder
    @id: -> 'PixelArtAcademy.LearnMode.Intro.TutorialsDrawing.PixelArtTools'
    
    @displayName: -> "Pixel art tools"
    
    @initialize()
