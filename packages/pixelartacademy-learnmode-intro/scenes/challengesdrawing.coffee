LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.ChallengesDrawing extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.DrawingChallenges'

  @location: -> PAA.Practice.Challenges.Drawing

  @initialize()
  
  constructor: ->
    super arguments...
    
    # Add/remove the reference selection asset to the copy reference challenge.
    @_referenceSelectionAutorun = Tracker.autorun =>
      return unless LOI.adventure.gameState()
      assets = PAA.Challenges.Drawing.PixelArtSoftware.state('assets') or []
      
      remainingAssetsCount = PAA.Challenges.Drawing.PixelArtSoftware.remainingCopyReferenceClasses().length
      referenceSelectionId = PAA.Challenges.Drawing.PixelArtSoftware.ReferenceSelection.id()
      referenceSelection = _.find assets, (asset) => asset.id is referenceSelectionId
  
      assets.unshift id: referenceSelectionId if remainingAssetsCount > 0 and not referenceSelection
      _.pull assets, referenceSelection if remainingAssetsCount is 0 and referenceSelection
      
      Tracker.nonreactive => PAA.Challenges.Drawing.PixelArtSoftware.state 'assets', assets

  destroy: ->
    super arguments...
  
    @_referenceSelectionAutorun.stop()

    @_pixelArtSoftware?.destroy()

  things: ->
    things = []
    DrawingApp = PAA.PixelPad.Apps.Drawing

    # Player needs the Desktop editor selected for the tutorial to display.
    situation = new LOI.Adventure.Situation location: PAA.Practice.Tutorials.Drawing
    return things unless basics = _.find situation.things(), (thing) => thing instanceof PAA.Tutorials.Drawing.PixelArtTools.Basics
    
    if DrawingApp.state('editorId') is PAA.PixelPad.Apps.Drawing.Editor.Desktop.id()
      if basics.completed()
        @_pixelArtSoftware ?= Tracker.nonreactive => new PAA.Challenges.Drawing.PixelArtSoftware

        things.push @_pixelArtSoftware

    things
