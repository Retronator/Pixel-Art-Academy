LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.TutorialsDrawing extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.TutorialsDrawing'

  @location: -> PAA.Practice.Tutorials.Drawing

  @initialize()
  
  destroy: ->
    super arguments...
  
    @_tutorialBasics?.destroy()
    @_tutorialColors?.destroy()
    @_tutorialHelpers?.destroy()

  things: ->
    return unless LM.Intro.Tutorial.Goals.PixelArtSoftware.active()

    things = []
    DrawingApp = PAA.PixelPad.Apps.Drawing

    # Player needs the Desktop editor selected for the tutorial to display.
    if DrawingApp.state('editorId') is PAA.PixelPad.Apps.Drawing.Editor.Desktop.id()
      @_tutorialBasics ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtTools.Basics
      things.push @_tutorialBasics

      if @_tutorialBasics.completed()
        @_tutorialColors ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtTools.Colors
        @_tutorialHelpers ?= Tracker.nonreactive => new PAA.Tutorials.Drawing.PixelArtTools.Helpers

        things.push @_tutorialColors, @_tutorialHelpers

    things
