AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.AssetOpenDialog extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Editor.AssetOpenDialog'
  @register @id()

  onCreated: ->
    super arguments...

    LOI.Assets.Asset.all.subscribe @, @interface.parent.assetClassName

    @selectedAssets = new ReactiveField []

  assets: ->
    @interface.parent.documentClass.documents.find {},
      sort:
        name: 1
        _id: 1

  nameOrId: ->
    data = @currentData()
    data.name or "#{data._id.substring 0, 5}…"

  selectedClass: ->
    'selected' if @currentData() in @selectedAssets()

  events: ->
    super(arguments...).concat
      'click .asset': @onClickAsset

  onClickNewAssetButton: (event) ->
    @selectedAssets [@currentData()]
