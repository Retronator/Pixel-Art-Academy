AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

PNG = require 'fast-png'

class LOI.Character extends LOI.Character
  @Meta
    name: @id()
    replaceParent: true

  @importDatabaseContent: (arrayBuffer) ->

  databaseContentPath: ->
    "landsofillusions/character/#{@debugName}"

  exportDatabaseContent: ->
    previewImage = @getPreviewImage()
    imageData = AM.EmbeddedImageData.embed previewImage, @

    # Encode the PNG.
    arrayBuffer = PNG.encode imageData

    arrayBuffer: arrayBuffer
    path: "#{@databaseContentPath()}.character.png"
    lastEditTime: new Date

  getPreviewImage: ->
    humanAvatar = new LOI.Character.Avatar @

    humanAvatarRenderer = new LOI.Character.Avatar.Renderers.HumanAvatar
      humanAvatar: humanAvatar
      useDatabaseSprites: true
    ,
      true

    previewImage = humanAvatarRenderer.getPreviewImage width: 40, height: 65

    humanAvatar.destroy()
    humanAvatarRenderer.destroy()

    previewImage
