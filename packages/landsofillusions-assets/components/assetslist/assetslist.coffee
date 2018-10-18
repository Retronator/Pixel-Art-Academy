AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.AssetsList extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.AssetsList'

  constructor: (@options) ->
    super

    @assetId = @options.getAssetId

  onCreated: ->
    super

    onSubscriptionReady = =>
      # Deselect asset if it gets deleted.
      @autorun (computation) =>
        return unless currentAssetId = @assetId()

        # See if the current asset exists.
        return if currentAssetId and @options.documentClass.documents.findOne currentAssetId

        # Clear the asset selection.
        @options.setAssetId null

    if @options.subscription
      @options.subscription.subscribe @, onSubscriptionReady

    else
      LOI.Assets.Asset.all.subscribe @, @options.documentClass.className, onSubscriptionReady

  assets: ->
    @options.documentClass.documents.find @options.selector or {},
      sort:
        name: 1
        _id: 1

  nameOrId: ->
    data = @currentData()
    data.name or "#{data._id.substring 0, 5}…"

  activeClass: ->
    'active' if @currentData()._id is @assetId()

  events: ->
    super.concat
      'click .new-asset-button': @onClickNewAssetButton
      'click .asset': @onClickAsset

  onClickNewAssetButton: (event) ->
    LOI.Assets.Asset.insert @options.documentClass.className, (error, assetId) =>
      if error
        console.error error
        return

      # Switch editor to the new asset.
      @options.setAssetId assetId

  onClickAsset: ->
    @options.setAssetId @currentData()._id
