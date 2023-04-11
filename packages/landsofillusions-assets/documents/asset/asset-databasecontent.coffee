AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

PNG = require 'fast-png'

class LOI.Assets.Asset extends LOI.Assets.Asset
  @deserializeDatabaseContent: (arrayBuffer) ->
    imageData = PNG.decode arrayBuffer
    AM.EmbeddedImageData.extract imageData

  getSaveData: ->
    # Override to add other properties to save.
    _.pick @, ['_id', 'name', 'history', 'historyPosition', 'lastEditTime', 'editor']

  getPreviewImage: -> throw new AE.NotImplementedException "Asset must provide a preview image for exporting database content."

  getDatabaseContent: ->
    saveData = @getSaveData()
    previewImage = @getPreviewImage()

    imageData = AM.EmbeddedImageData.embed previewImage, saveData

    # Encode the PNG.
    arrayBuffer = PNG.encode imageData
  
    plainData: saveData
    arrayBuffer: arrayBuffer
    path: "#{@name or @_id}.#{_.toLower @constructor.className}.png"
    lastEditTime: @lastEditTime
