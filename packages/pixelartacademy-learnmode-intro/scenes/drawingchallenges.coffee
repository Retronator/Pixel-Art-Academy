LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.DrawingChallenges extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.DrawingChallenges'

  @location: -> PAA.Practice.Challenges.Drawing

  @initialize()

  destroy: ->
    super arguments...

    @_pixelArtSoftware?.destroy()
    @_tutorialBasics?.destroy()
    @_tutorialColors?.destroy()
    @_tutorialHelpers?.destroy()

  things: ->
    things = []
    DrawingApp = PAA.PixelBoy.Apps.Drawing

    # Player needs the Desktop editor selected for the tutorial to display.
    if DrawingApp.state('editorId') is PAA.PixelBoy.Apps.Drawing.Editor.Desktop.id()
      @_tutorialBasics ?= Tracker.nonreactive => new PAA.Challenges.Drawing.Tutorial.Basics
      things.push @_tutorialBasics

      if @_tutorialBasics.completed()
        @_tutorialColors ?= Tracker.nonreactive => new PAA.Challenges.Drawing.Tutorial.Colors
        @_tutorialHelpers ?= Tracker.nonreactive => new PAA.Challenges.Drawing.Tutorial.Helpers
        @_pixelArtSoftware ?= Tracker.nonreactive => new PAA.Challenges.Drawing.PixelArtSoftware

        things.push @_tutorialColors, @_tutorialHelpers, @_pixelArtSoftware

    # If the player has an editor or external software selected, we show the Pixel Art Tools challenge.
    if DrawingApp.state('editorId') or DrawingApp.state('externalSoftware')
      things.push @_pixelArtSoftware

    things
