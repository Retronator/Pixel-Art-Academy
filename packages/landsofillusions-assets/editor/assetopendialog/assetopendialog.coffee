AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.AssetOpenDialog extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Editor.AssetOpenDialog'
  @register @id()

  # We explicitly define the template to allow inheritance.
  template: -> 'LandsOfIllusions.Assets.Editor.AssetOpenDialog'

  onCreated: ->
    super arguments...

    @fileManager = new LOI.Assets.Editor.FileManager @_fileManagerOptions()

    @_subscribeToDocuments()

  _fileManagerOptions: ->
    # Override to provide options for the file manager.

    documents: @interface.parent.documentClass.documents
    defaultOperation: => @_open()

  _subscribeToDocuments: ->
    # Override to subscribe to documents for the file manager.

    subscription = @interface.parent.documentClass.allSystem or @interface.parent.documentClass.all
    subscription.subscribe @, @interface.parent.assetClassName
    
  closeDialog: ->
    dialogData = @ancestorComponentOfType(FM.FloatingArea).data()
    @interface.closeDialog dialogData

  events: ->
    super(arguments...).concat
      'click .cancel-button': @onClickCancelButton
      'click .open-button': @onClickOpenButton

  onClickCancelButton: (event) ->
    @closeDialog()

  onClickOpenButton: (event) ->
    @_open()

  _open: ->
    # Override to provide an action on open.
    
    # Find the editor view in the interface.
    editorViews = @interface.allChildComponentsOfType FM.EditorView

    unless editorViews.length
      throw new AE.InvalidOperationException "There is no EditorView in the interface."
      
    # TODO: Select the editor view that hosts the currently active file. For now we just take the first.
    targetEditorView = editorViews[0]
    
    # Open all the files in the target editor view.
    for item in @fileManager.selectedItems()
      if item instanceof LOI.Assets.Editor.FileManager.Directory.Folder
        # We have a directory. See if its extension indicates a package of files.
        if _.endsWith item.name, '.rot8'
          targetEditorView.addFile item.name, LOI.Assets.Sprite.Rot8.id()

      else
        targetEditorView.addFile item._id, item.constructor.id()
    
    @closeDialog()
