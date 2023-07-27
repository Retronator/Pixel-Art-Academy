LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Tutorials.Drawing.Tutorial extends LOI.Adventure.Thing
  # assets: array of assets that are part of this tutorial
  #   id: unique asset identifier
  #   type: what kind of asset this is
  #   completed: auto-updated field if the player completed this asset
  #
  #   BITMAP
  #   bitmap: reference to a bitmap
  #     _id
  @assets: -> [] # Override to provide asset classes that are included in this tutorial.

  @assetsCount: -> @assets().length

  @completedAssetsCount: ->
    assets = @state('assets') or []
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

  completed: -> @constructor.completed()
  isAssetCompleted: (assetClassOrId) -> @constructor.isAssetCompleted assetClassOrId

  assetsData: ->
    return unless LOI.adventure.gameState()

    # We need to mimic a project, so we need to provide the data. If no state is
    # set, we send a dummy object to let the bitmap know we've loaded the state.
    @state('assets') or []

  _assetsCompleted: (assets...) ->
    for asset in assets
      return unless asset
      return unless @isAssetCompleted asset

    true

  _assetsComparison: (a, b) =>
    # We consider assets have changed only when the array values differ.
    return unless a.length is b.length

    for asset, index in a
      return unless asset is b[index]

    true