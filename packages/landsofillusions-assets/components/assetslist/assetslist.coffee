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
      # Always show the first asset image if none is displayed.
      @autorun (computation) =>
        currentAssetId = @assetId()

        # Make sure the current asset exists.
        return if currentAssetId and @options.documentClass.documents.findOne currentAssetId

        # Switch to the first asset image on the display list.
        asset = @assets().fetch()[0]
        @options.setAssetId asset?._id or null

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
      'click .new-asset-button': @onClickNewAssetButton
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
