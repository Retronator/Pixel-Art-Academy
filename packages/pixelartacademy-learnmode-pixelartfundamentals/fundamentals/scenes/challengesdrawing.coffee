LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.ChallengesDrawing extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.DrawingChallenges'

  @location: -> PAA.Practice.Challenges.Drawing

  @initialize()
  
  constructor: ->
    super arguments...
    
    # Add/remove the reference selection asset to the pixel art line art challenge.
    @_referenceSelectionAutorun = Tracker.autorun =>
      return unless LOI.adventure.gameState()
      assets = PAA.Challenges.Drawing.PixelArtLineArt.state('assets') or []
      
      remainingAssetsCount = PAA.Challenges.Drawing.PixelArtLineArt.remainingDrawLineArtClasses().length
      referenceSelectionId = PAA.Challenges.Drawing.PixelArtLineArt.ReferenceSelection.id()
      referenceSelection = _.find assets, (asset) => asset.id is referenceSelectionId
  
      assets.unshift id: referenceSelectionId if remainingAssetsCount > 0 and not referenceSelection
      _.pull assets, referenceSelection if remainingAssetsCount is 0 and referenceSelection
      
      Tracker.nonreactive => PAA.Challenges.Drawing.PixelArtLineArt.state 'assets', assets

  destroy: ->
    super arguments...
  
    @_referenceSelectionAutorun.stop()

    @_pixelArtLineArt?.destroy()

  things: ->
    things = []
    
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.completed()
      @_pixelArtLineArt ?= Tracker.nonreactive => new PAA.Challenges.Drawing.PixelArtLineArt

      things.push @_pixelArtLineArt

    things
