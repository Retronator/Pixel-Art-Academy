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
      defaultOperation: => @_open()

    LOI.Assets.Asset.all.subscribe @, @interface.parent.assetClassName

    @selectedAssets = new ReactiveField []
    
  closeDialog: ->
    dialogData = @ancestorComponentOfType(FM.FloatingArea).data()
    @interface.closeDialog dialogData

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
    @closeDialog()

  onClickOpenButton: (event) ->
    @_open()

  _open: ->
    # Find the editor view in the interface.
    editorViews = @interface.allChildComponentsOfType FM.EditorView

    unless editorViews.length
      throw new AE.InvalidOperationException "There is no EditorView in the interface."
      
    # TODO: Select the editor view that hosts the currently active file. For now we just take the first.
    targetEditorView = editorViews[0]
    
    # Open all the files in the target editor view.
    for item in @fileManager.selectedItems()
      targetEditorView.addFile item._id
    
    @closeDialog()
