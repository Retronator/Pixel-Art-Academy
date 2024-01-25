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
    assets = @state 'assets'
    _.find assets, (asset) => asset.completed
  
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
    
    @completedBitmapIds = new AE.LiveComputedField =>
      assets = @state 'assets'
      completedAssets = _.filter assets, (asset) => asset.completed
      asset.bitmapId for asset in completedAssets
    
    # Listen to a change in completed of assets to determine which pixel art evaluation criteria can be granted.
    @_completedAutorun = Tracker.autorun =>
      completedBitmapIds = @completedBitmapIds()
      
      Tracker.nonreactive =>
        unlockedPixelArtEvaluationCriteria = []
        
        for bitmapId in completedBitmapIds
          bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
          
          for criterion of PAA.Practice.PixelArtEvaluation.Criteria
            criterionProperty = _.lowerFirst criterion
            continue unless bitmap.properties?.pixelArtEvaluation?[criterionProperty]?.score >= 0.9

            unlockedPixelArtEvaluationCriteria.push criterion unless criterion in unlockedPixelArtEvaluationCriteria
        
        PAA.Practice.Project.Asset.Bitmap.state 'unlockedPixelArtEvaluationCriteria', unlockedPixelArtEvaluationCriteria

  destroy: ->
    @completedBitmapIds.stop()
    @_completedAutorun.stop()
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
  
