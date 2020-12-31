AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.ResetInterface extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.ResetInterface'
  @displayName: -> "Reset interface"

  @initialize()

  execute: ->
    editor = @interface.parent

    # Reset user interface, but preserve editor view data.
    newInterfaceData = editor.constructor.defaultInterfaceData()
    editorViews = @interface.allChildComponentsOfType FM.EditorView

    if editorViews.length
      for editorView in editorViews
        data = editorView.data()
        _.nestedProperty newInterfaceData, data.options.address, data.value()

    # Also keep the currently active tool and file.
    newInterfaceData.activeToolId = @interface.activeToolId()
    newInterfaceData.activeFileId = @interface.activeFileId()

    editor.localInterfaceData newInterfaceData
