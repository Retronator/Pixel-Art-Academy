AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.AssetOpenDialog extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Editor.AssetOpenDialog'
  @register @id()

  constructor: (@options) ->
    super arguments...

    @assetId = @options.getAssetId

  onCreated: ->
    super arguments...

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
    super(arguments...).concat
      # HACK: Wiring this to mousedown to prevent a bug that triggers click of this button when
      # clicking anywhere in the component. This only appears when component is embedded deep within.
      'mousedown .new-asset-button': @onClickNewAssetButton
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
