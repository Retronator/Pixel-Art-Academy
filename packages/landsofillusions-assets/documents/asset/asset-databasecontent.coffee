AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

PNG = require 'fast-png'

class LOI.Assets.Asset extends LOI.Assets.Asset
  @importDatabaseContent: (arrayBuffer) ->
    imageData = PNG.decode arrayBuffer
    AM.EmbeddedImageData.extract imageData

  getSaveData: ->
    # Override to add other properties to save.
    _.pick @, ['_id', 'name', 'history', 'historyPosition', 'lastEditTime', 'editor']

  getPreviewImage: -> throw new AE.NotImplementedException "Asset must provide a preview image for exporting database content."

  exportDatabaseContent: ->
    saveData = @getSaveData()
    previewImage = @getPreviewImage()

    imageData = AM.EmbeddedImageData.embed previewImage, saveData

    # Encode the PNG.
    arrayBuffer = PNG.encode imageData

    arrayBuffer: arrayBuffer
    path: "#{@name or @_id}.#{_.toLower @constructor.className}.png"
    lastEditTime: @lastEditTime
