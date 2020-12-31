AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

Archiver = require 'archiver'

WebApp.connectHandlers.use '/admin/landsofillusions/characters/assets/actorassets.zip', (request, response, next) ->
  query = request.query
  adminPassword = Meteor.settings.admin?.password or ''

  try
    if query.userId
      userId = CryptoJS.AES.decrypt(query.userId, adminPassword).toString CryptoJS.enc.Latin1
      RA.authorizeAdmin {userId}

    else
      throw new AE.UnauthorizedException

    response.writeHead 200,
      'Content-Type': 'application/zip'
      'Content-Disposition': 'attachment; filename="actorassets.zip"'

    archive = Archiver 'zip', zlib: level: 9
    archive.pipe response
    archive.on 'end', -> response.end()

    # Export textures and json of all administrator's characters.
    admin = RA.User.documents.findOne username: 'admin'
    throw new AE.InvalidOperationException "Administrator could not be found." unless admin

    for character in admin.characters
      character.refresh()

      # NPCs will all have a thing ID as they get imported into the database.
      continue unless character.thingId

      idParts = character.thingId.split '.'
      idParts = _.map idParts, _.toLower
      path = idParts.join '/'

      console.log "Exporting character #{character.thingId} to #{path}"
      character._id = character.thingId
      delete character.thingId

      # Export the json file.
      archive.append EJSON.stringify(character, indent: true), name: "#{path}.json"

      # Render the textures.
      humanAvatar = new LOI.Character.Avatar character

      humanAvatarRenderer = new LOI.Character.Avatar.Renderers.HumanAvatar
        humanAvatar: humanAvatar
        renderTexture: true
        useDatabaseSprites: true
      ,
        true

      textureRenderer = new LOI.HumanAvatar.TextureRenderer {humanAvatar, humanAvatarRenderer}
      result = textureRenderer.render()
      throw new AE.ArgumentException "Texture renderer could not render the provided avatar." unless result

      for textureName in ['PaletteData', 'Normals']
        canvasField = "scaled#{textureName}Canvas"
        canvas = textureRenderer[canvasField]

        buffer = canvas.toBuffer 'image/png',
          compressionLevel: 9

        archive.append Buffer.from(buffer), name: "#{path}-#{textureName.toLowerCase()}.png"

      humanAvatarRenderer.destroy()
      humanAvatar.destroy()

    # Complete exporting.
    archive.finalize()

    console.log "Actor assets export done!"

  catch error
    console.error error
    response.writeHead 400, 'Content-Type': 'text/txt'
    response.end "You do not have permission to download NPC assets."
