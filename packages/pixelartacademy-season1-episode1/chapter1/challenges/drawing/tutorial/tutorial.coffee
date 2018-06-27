AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial extends LOI.Adventure.Thing
  # assets: array of assets that are part of this tutorial
  #   id: unique asset identifier
  #   completed: auto-updated field if the player completed this asset
  #
  # READONLY
  # assets: array of assets that are part of this tutorial
  #   id: unique asset identifier
  #   type: what kind of asset this is
  #
  #   SPRITE
  #   sprite: reference to a sprite
  #     _id
  @completed: -> throw new AE.NotImplementedException "You must determine when a tutorial is completed."

  @isAssetCompleted: (assetClassOrId) ->
    return unless assets = @state 'assets'

    assetId = _.thingId assetClassOrId
    return unless asset = _.find assets, (asset) => asset.id is assetId

    asset.completed

  assetsData: ->
    return unless LOI.adventure.readOnlyGameState()

    # We need to mimic a project, so we need to provide the data. If no state is 
    # set, we send a dummy object to let the sprite know we've loaded the state.
    @readOnlyState('assets') or []

  _assetsCompleted: (assets...) ->
    for asset in assets
      return unless asset?.completed()

    true

  _assetsComparison: (a, b) =>
    # We consider assets have changed only when the array values differ.
    return unless a.length is b.length

    for asset, index in a
      return unless asset is b[index]

    true

  completed: ->
    @constructor.completed()
