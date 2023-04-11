AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

PNG = require 'fast-png'

class LOI.Character extends LOI.Character
  @Meta
    name: @id()
    replaceParent: true

  @deserializeDatabaseContent: (arrayBuffer) ->
    imageData = PNG.decode arrayBuffer
    AM.EmbeddedImageData.extract imageData

  databaseContentPath: ->
    "landsofillusions/character/#{@debugName}"

  getDatabaseContent: ->
    # Add last edit time if needed so that documents don't need unnecessary imports.
    @lastEditTime ?= new Date()

    previewImage = @getPreviewImage()
    imageData = AM.EmbeddedImageData.embed previewImage, @

    # Encode the PNG.
    arrayBuffer = PNG.encode imageData
  
    plainData: @
    arrayBuffer: arrayBuffer
    path: "#{@databaseContentPath()}.character.png"
    lastEditTime: @lastEditTime

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
