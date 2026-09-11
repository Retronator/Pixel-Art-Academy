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
      return unless LOI.adventure.gameStateAvailable()
      assets = PAA.Challenges.Drawing.PixelArtSoftware.state('assets') or []
      
      remainingAssetsCount = PAA.Challenges.Drawing.PixelArtSoftware.remainingCopyReferenceClasses().length
      referenceSelectionId = PAA.Challenges.Drawing.PixelArtSoftware.ReferenceSelection.id()
      referenceSelection = _.find assets, (asset) => asset.id is referenceSelectionId
  
      if remainingAssetsCount > 0 and not referenceSelection
        assets.unshift id: referenceSelectionId
        assetsChanged = true
      
      if remainingAssetsCount is 0 and referenceSelection
        _.pull assets, referenceSelection
        assetsChanged = true
      
      return unless assetsChanged
      
      Tracker.nonreactive => PAA.Challenges.Drawing.PixelArtSoftware.state 'assets', assets

  destroy: ->
    super arguments...
  
    @_referenceSelectionAutorun.stop()

    @_pixelArtSoftware?.destroy()

  things: ->
    things = []

    if LM.Intro.Tutorial.Goals.PixelArtSoftware.addedAndAvailable()
      if PAA.Tutorials.Drawing.PixelArtTools.Basics.completed()
        @_pixelArtSoftware ?= Tracker.nonreactive => new PAA.Challenges.Drawing.PixelArtSoftware
  
        things.push @_pixelArtSoftware

    things
