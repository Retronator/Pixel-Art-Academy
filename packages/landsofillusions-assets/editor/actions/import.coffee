AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

BSON = require 'bson'
Pako = require 'pako'
PNG = require 'fast-png'

class LOI.Assets.Editor.Actions.Import extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Import'
  @displayName: -> "Import"

  @initialize()

  execute: ->
    # Ask user for file.
    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]

      # Load the image.
      fileReader = new FileReader
      fileReader.addEventListener 'load', =>
        imageData = PNG.decode fileReader.result

        # Retrieve asset from image data.
        asset = @_readData imageData

        @_saveAsset asset

      fileReader.readAsArrayBuffer file

    $fileInput.click()

  _readData: (imageData) ->
    # Read embedded information.
    embeddedData = new Uint8Array imageData.width * imageData.height * 4
    header = new Uint32Array embeddedData.buffer, 0, 1

    x = 0
    y = 0
    retrieveWidth = imageData.width - 1
    retrieveHeight = imageData.height - 1
    retrieveRemaining = retrieveWidth
    dx = 1
    dy = 0

    for dataIndex in [0...embeddedData.length]
      index = (x + y * imageData.width) * 4

      break if dataIndex > 4 and dataIndex >= header[0] + 4

      value = 0

      for offset in [0..3]
        # Get 2 bits of the value.
        value += (imageData.data[index + offset] & 3) << offset * 2

      embeddedData[dataIndex] = value

      # Progress around the border.
      x += dx
      y += dy

      retrieveRemaining--
      continue if retrieveRemaining

      if dx
        dy = dx
        dx = 0
        retrieveRemaining = retrieveHeight

      else
        if dy > 0
          dx = -1

        else
          dx = 1
          retrieveWidth -= 2
          retrieveHeight -= 2
          x++
          y++

        dy = 0
        retrieveRemaining = retrieveWidth

    compressedBinaryDataLength = header[0]
    compressedBinaryData = new Uint8Array embeddedData.buffer, 4, compressedBinaryDataLength

    binaryData = Pako.inflateRaw compressedBinaryData
    BSON.deserialize binaryData

  _saveAsset: (asset) ->
    assetClassName = @interface.parent.assetClassName

    LOI.Assets.Asset.exists assetClassName, asset._id, (error, exists) =>
      if error
        console.error error
        return

      unless exists
        LOI.Assets.Asset.insert asset

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

            LOI.Assets.Asset.update assetClassName, asset._id, asset, upsert: true

            # Open the imported asset.
            editorViews = @interface.allChildComponentsOfType FM.EditorView
            targetEditorView = editorViews[0]
            targetEditorView.addFile asset._id, @constructor.assetClass.id()
