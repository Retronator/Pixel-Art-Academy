LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Tutorials.Drawing.Tutorial extends LOI.Adventure.Thing
  # assets: array of assets that are part of this tutorial
  #   id: unique asset identifier
  #   type: what kind of asset this is
  #   completed: auto-updated field if the player completed this asset
  #
  #   BITMAP
  #   bitmapId: ID of the bitmap representing this asset
  @assets: -> [] # Override to provide asset classes that are included in this tutorial.

  @assetsCount: -> @assets().length

  @completedAssetsCount: ->
    # Due to changes in the curriculum, we have to filter assets to the ones that are currently enabled.
    @_assetIds ?= (asset.id() for asset in @assets())
  
    assets = _.filter @state('assets') or [], (asset) => asset.id in @_assetIds
    
    _.sum ((if asset.completed then 1 else 0) for asset in assets)

  @completedRatio: -> @completedAssetsCount() / @assetsCount()

  # By default we have to complete all assets to complete the tutorial.
  @requiredAssetsCount: -> @assetsCount()
  @requiredCompletedAssetsCount: -> @completedAssetsCount()
  @requiredCompletedRatio: -> @completedRatio()

  @completed: -> @requiredCompletedRatio() is 1

  @isAssetCompleted: (assetClassOrId) ->
    return unless assets = @state 'assets'

    assetId = _.thingId assetClassOrId
    return unless asset = _.find assets, (asset) => asset.id is assetId

    asset.completed

  constructor: ->
    super arguments...
    
    @_assets = []

    @assets = new ComputedField =>
      assets = []
      
      for assetClass, index in @constructor.assets()
        @_assets[index] ?= Tracker.nonreactive => new assetClass @
        assets.unshift @_assets[index]
        
        break unless @isAssetCompleted @_assets[index]

      assets
    ,
      @_assetsComparison
    ,
      true

  destroy: ->
    asset.destroy() for asset in @_assets

    @assets.stop()
    
  completed: -> @constructor.completed()
  isAssetCompleted: (assetClassOrId) -> @constructor.isAssetCompleted assetClassOrId

  assetsData: ->
    return unless LOI.adventure.gameState()

    # We need to mimic a project, so we need to provide the data. If no state is
    # set, we send a dummy object to let the bitmap know we've loaded the state.
    @state('assets') or []

  _assetsComparison: (a, b) =>
    # We consider assets have changed only when the array values differ.
    return unless a.length is b.length

    for asset, index in a
      return unless asset is b[index]

    true
