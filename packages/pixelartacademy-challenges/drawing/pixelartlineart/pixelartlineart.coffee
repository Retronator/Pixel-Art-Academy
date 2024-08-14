AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtLineArt extends LOI.Adventure.Thing
  # assets: array of assets that the player has chosen to complete for the line art challenges
  #   id: unique asset identifier
  #   type: what kind of asset this is
  #   completed: auto-updated field if the player completed this asset
  #
  #   BITMAP
  #   bitmapId: ID of the bitmap representing this asset
  @id: -> 'PixelArtAcademy.Challenges.Drawing.PixelArtLineArt'

  @fullName: -> "Pixel art line art"

  @initialize()
  
  @drawLineArtClasses = {}

  @completed: ->
    _.every [
      @completedPixelPerfectLines()
      @completedEvenDiagonals()
      @completedSmoothCurves()
    ]
  
  @completedPixelPerfectLines: ->
    assets = @state 'assets'
    
    _.find assets, (asset) =>
      return unless bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId asset.bitmapId
      return unless pixelPerfectLines = bitmap.properties?.pixelArtEvaluation?.pixelPerfectLines
      
      _.every [
        asset.completed
        pixelPerfectLines.score >= 0.8
        pixelPerfectLines.doubles?
        pixelPerfectLines.corners?
      ]
      
  @completedEvenDiagonals: ->
    assets = @state 'assets'
    
    _.find assets, (asset) =>
      return unless bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId asset.bitmapId
      return unless evenDiagonals = bitmap.properties?.pixelArtEvaluation?.evenDiagonals
      
      _.every [
        asset.completed
        evenDiagonals.score >= 0.8
        evenDiagonals.segmentLengths?.counts?.even > 10
      ]
      
  @completedSmoothCurves: ->
    assets = @state 'assets'
    
    _.find assets, (asset) =>
      return unless bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId asset.bitmapId
      return unless smoothCurves = bitmap.properties?.pixelArtEvaluation?.smoothCurves
      
      _.every [
        asset.completed
        smoothCurves.score >= 0.8
        smoothCurves.abruptSegmentLengthChanges?.score >= 0.8
        smoothCurves.straightParts?.score >= 0.8
        smoothCurves.inflectionPoints?.score >= 0.8
      ]
      
  @completedConsistentLineWidth: ->
    assets = @state 'assets'
    
    _.find assets, (asset) =>
      return unless bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId asset.bitmapId
      return unless consistentLineWidth = bitmap.properties?.pixelArtEvaluation?.consistentLineWidth
      
      _.every [
        asset.completed
        consistentLineWidth.individualConsistency?.score >= 0.8 or consistentLineWidth.globalConsistency?.score >= 0.8
      ]
  
  @addDrawLineArtAsset: (id) ->
    assets = @state 'assets'
    assets ?= []
    
    # Add the asset if it's not already added.
    unless _.find(assets, (asset) => asset.id is id)
      referenceSelectionId = PAA.Challenges.Drawing.PixelArtLineArt.ReferenceSelection.id()
      referenceSelection = _.find assets, (asset) => asset.id is referenceSelectionId
      
      insertionIndex = if referenceSelection then 1 else 0
      assets.splice insertionIndex, 0, {id}
    
    @state 'assets', assets
    
  @remainingDrawLineArtClasses: ->
    addedAssets = @state('assets') or []
    addedReferenceClassIds = (asset.id for asset in addedAssets)
    
    _.filter _.values(@drawLineArtClasses), (drawLineArtClass) => drawLineArtClass.id() not in addedReferenceClassIds
    
  constructor: ->
    super arguments...
    
    # Listen to a change in completed tutorials to determine which pixel art evaluation criteria can be challenged.
    requiredTutorials =
      PixelPerfectLines: PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines
      EvenDiagonals: PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals
      SmoothCurves: PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves
      ConsistentLineWidth: PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth
    
    @_unlockableCriteriaAutorun = Tracker.autorun =>
      unlockablePixelArtEvaluationCriteria = []
      
      for criterion, tutorial of requiredTutorials when tutorial.completed()
        unlockablePixelArtEvaluationCriteria.push criterion
        
      # See if the criteria actually changed.
      existingUnlockablePixelArtEvaluationCriteria = PAA.Practice.Project.Asset.Bitmap.state 'unlockablePixelArtEvaluationCriteria'
      return unless _.xor(unlockablePixelArtEvaluationCriteria, existingUnlockablePixelArtEvaluationCriteria).length
    
      PAA.Practice.Project.Asset.Bitmap.state 'unlockablePixelArtEvaluationCriteria', unlockablePixelArtEvaluationCriteria
    
    # Listen to a change in completed of assets to determine which pixel art evaluation criteria can be granted.
    @completedChallenges = new AE.LiveComputedField =>
      PixelPerfectLines: Boolean @constructor.completedPixelPerfectLines()
      EvenDiagonals: Boolean @constructor.completedEvenDiagonals()
      SmoothCurves: Boolean @constructor.completedSmoothCurves()
      ConsistentLineWidth: Boolean @constructor.completedConsistentLineWidth()
    ,
      EJSON.equals
    
    @_unlockedCriteriaAutorun = Tracker.autorun =>
      unlockedPixelArtEvaluationCriteria = []
      
      for criterion, completed of @completedChallenges() when completed
        unlockedPixelArtEvaluationCriteria.push criterion
      
      # See if the criteria actually changed.
      existingUnlockedPixelArtEvaluationCriteria = PAA.Practice.Project.Asset.Bitmap.state 'unlockedPixelArtEvaluationCriteria'
      return unless _.xor(unlockedPixelArtEvaluationCriteria, existingUnlockedPixelArtEvaluationCriteria).length
      
      PAA.Practice.Project.Asset.Bitmap.state 'unlockedPixelArtEvaluationCriteria', unlockedPixelArtEvaluationCriteria

  destroy: ->
    @_unlockableCriteriaAutorun.stop()
    @completedChallenges.stop()
    @_unlockedCriteriaAutorun.stop()
    
    asset.destroy() for asset in @_pixelArtLineArtAssets if @_pixelArtLineArtAssets

  assetsData: ->
    return unless LOI.adventure.gameState()

    # We need to mimic a project, so we need to provide the data. If no state is
    # set, we send a dummy object to let the bitmap know we've loaded the state.
    @state('assets') or []

  assets: ->
    assets = []
    
    @_pixelArtLineArtAssets ?= []
    
    if pixelArtLineArtAssets = @state 'assets'
      for asset in pixelArtLineArtAssets
        if asset.id is PAA.Challenges.Drawing.PixelArtLineArt.ReferenceSelection.id()
          @_pixelArtLineArtAssets[asset.id] ?= Tracker.nonreactive => new PAA.Challenges.Drawing.PixelArtLineArt.ReferenceSelection @
        
        else
          assetClassName = _.last asset.id.split '.'
          @_pixelArtLineArtAssets[asset.id] ?= Tracker.nonreactive => new PAA.Challenges.Drawing.PixelArtLineArt.DrawLineArt[assetClassName] @
        
        assets.push @_pixelArtLineArtAssets[asset.id]

    assets
    
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtLineArt
