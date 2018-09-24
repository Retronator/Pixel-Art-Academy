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

    @options.documentClass.all.subscribe @, =>
      # Deselect asset if it gets deleted.
      @autorun (computation) =>
        return unless currentAssetId = @assetId()

        # See if the current asset exists.
        return if currentAssetId and @options.documentClass.documents.findOne currentAssetId

        # Clear the asset selection.
        @options.setAssetId null

  assets: ->
    @options.documentClass.documents.find {},
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
      # HACK: Wiring this to mousedown to prevent a bug that triggers click of this button when
      # clicking anywhere in the component. This only appears when component is embedded deep within.
      'mousedown .new-asset-button': @onClickNewAssetButton
      'click .asset': @onClickAsset

  onClickNewAssetButton: (event) ->
    @options.documentClass.insert (error, assetId) =>
      if error
        console.error error
        return

      # Switch editor to the new asset.
      @options.setAssetId assetId

  onClickAsset: ->
    @options.setAssetId @currentData()._id
