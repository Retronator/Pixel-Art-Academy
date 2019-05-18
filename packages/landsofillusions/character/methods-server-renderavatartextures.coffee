AE = Artificial.Everywhere
LOI = LandsOfIllusions

{Uploader} = require 's3-streaming-upload'
{PassThrough} = require 'stream'

LOI.Character.renderAvatarTextures.method (characterId) ->
  check characterId, Match.DocumentId

  throw new AE.ExternalException "Amazon Web Services not configured." unless Meteor.settings.amazonWebServices?.accessKey

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  character = LOI.Character.documents.findOne characterId
  throw new AE.InvalidOperationException "Character's design hasn't been approved yet." unless character.designApproved
  throw new AE.InvalidOperationException "Character's avatar textures don't need to be updated." unless character.avatar?.textures?.needUpdate
  
  humanAvatar = new LOI.Character.Avatar character
  
  humanAvatarRenderer = new LOI.Character.Avatar.Renderers.HumanAvatar
    humanAvatar: humanAvatar
    renderTexture: true
    useDatabaseSprites: true
  ,
    true

  # Render the textures.
  textureRenderer = new LOI.HumanAvatar.TextureRenderer {humanAvatar, humanAvatarRenderer, createCanvas}
  textureRenderer.render()

  paletteDataPNGStream = textureRenderer.scaledPaletteDataCanvas.createPNGStream
    compressionLevel: 9

  normalsPNGStream = textureRenderer.scaledNormalsCanvas.createPNGStream
    compressionLevel: 9

  # Upload the textures to storage server.
  upload = (stream, textureName) =>
    passthrough = new PassThrough()
    stream.pipe passthrough

    uploader = new Uploader
      accessKey: Meteor.settings.amazonWebServices.accessKey
      secretKey: Meteor.settings.amazonWebServices.secret
      bucket: 'pixelartacademy'
      objectName: "avatars/#{characterId}-#{textureName}.png"
      stream: stream
      objectParams:
        ACL: 'public-read'
        Body: passthrough
        ContentType: 'image/png'

    # Return a promise for the uploading file.
    new Promise (resolve, reject) =>
      uploader.send (error) ->
        if error
          console.error "Avatar textures render for", characterId, "encountered an error on upload.", error
          reject()
          return

        resolve()

  uploadPromises = [
    upload paletteDataPNGStream, 'palettedata'
    upload normalsPNGStream, 'normals'
  ]

  Promise.all(uploadPromises).then =>
    version = (character.avatar.textures.version or 0) + 1

    LOI.Character.documents.update characterId,
      $set:
        'avatar.textures.paletteData.url': "https://pixelartacademy.s3.amazonaws.com/avatars/#{characterId}-palettedata.png?#{version}"
        'avatar.textures.normals.url': "https://pixelartacademy.s3.amazonaws.com/avatars/#{characterId}-normals.png?#{version}"
        'avatar.textures.version': version
        'avatar.textures.needUpdate': false
