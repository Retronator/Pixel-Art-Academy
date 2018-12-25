AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.AssetOpenDialog extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Editor.AssetOpenDialog'
  @register @id()

  onCreated: ->
    super arguments...

    @fileManager = new LOI.Assets.Components.FileManager
      documents: LOI.Assets.Sprite.documents

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
      'click .cancel-button': @onClickCancelButton
      'click .open-button': @onClickOpenButton

  onClickCancelButton: (event) ->
    dialogData = @ancestorComponentOfType(FM.FloatingArea).data()
    @interface.closeDialog dialogData

  onClickOpenButton: (event) ->
    console.log "Opening", @fileManager.selectedItems()
