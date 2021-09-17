AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

PNG = require 'fast-png'

class LOI.Assets.Editor.Actions.Import extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Import'
  @displayName: -> "Import …"

  @initialize()

  execute: ->
    # Ask user for file.
    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]

      # Load the image.
      fileReader = new FileReader
      fileReader.addEventListener 'load', =>
        # Retrieve asset from image.
        asset = LOI.Assets.Asset.importDatabaseContent fileReader.result

        @_saveAsset asset

      fileReader.readAsArrayBuffer file

    $fileInput.click()

  _saveAsset: (asset) ->
    assetClassName = @interface.parent.assetClassName

    LOI.Assets.Asset.exists assetClassName, asset._id, (error, exists) =>
      if error
        console.error error
        return

      addAndOpen = =>
        LOI.Assets.Asset.update assetClassName, asset._id, asset, upsert: true

        # Open the imported asset.
        editorViews = @interface.allChildComponentsOfType FM.EditorView
        targetEditorView = editorViews[0]
        targetEditorView.addFile asset._id, @interface.parent.documentClass.id()

      unless exists
        addAndOpen()
        return

      # Ask the user if they want to overwrite, keep both, or cancel the action.
      answers =
        Overwrite: "Overwrite"
        KeepBoth: "KeepBoth"
        Cancel: "Cancel"

      @interface.displayDialog
        contentComponentId: LOI.Assets.Editor.Dialog.id()
        contentComponentData:
          title: "Import #{assetClassName}"
          message: "A file with this ID already exists."
          moreInfo: "Do you want to overwrite it, keep both files, or cancel import?"
          buttons: [
            text: "Overwrite"
            value: answers.Overwrite
          ,
            text: "Keep both"
            value: answers.KeepBoth
          ,
            text: "Cancel"
            value: answers.Cancel
          ]
          callback: (answer) =>
            switch answer
              when answers.Cancel
                return
              when answers.KeepBoth
                asset._id = Random.id()

            addAndOpen()
