AE = Artificial.Everywhere
LOI = LandsOfIllusions
RA = Retronator.Accounts
Request = request

WebApp.connectHandlers.use '/admin/landsofillusions/characters/assets/avatartexture.png', (request, response, next) ->
  query = request.query
  adminPassword = Meteor.settings.admin?.password or ''

  try
    if query.id
      characterId = CryptoJS.AES.decrypt(query.id, adminPassword).toString CryptoJS.enc.Latin1
      character = LOI.Character.documents.findOne characterId
      throw new AE.ArgumentException "Character not found." unless character

    else if query.url
      # Create a local URL if needed.
      characterUrl = Meteor.absoluteUrl "packages/#{CryptoJS.AES.decrypt(query.url, adminPassword).toString CryptoJS.enc.Latin1}"
      characterResponse = Request.getSync characterUrl, encoding: null

      throw new AE.ArgumentException "URL did not point to a JSON file." unless _.startsWith characterResponse.response.headers['content-type'], 'application/json'

      character = EJSON.parse characterResponse.body.toString()

    else
      throw new AE.ArgumentNullException "Character not specified."

    switch query.texture
      when 'paletteData'
        canvasField = 'scaledPaletteDataCanvas'

      when 'normal'
        canvasField = 'scaledNormalsCanvas'

      else
        throw new AE.ArgumentException "You must specify either 'paletteData' or 'normal' in the texture parameter."

    humanAvatar = new LOI.Character.Avatar character

    humanAvatarRenderer = new LOI.Character.Avatar.Renderers.HumanAvatar
      humanAvatar: humanAvatar
      renderTexture: true
      useDatabaseSprites: true
    ,
      true

    # Render the textures.
    textureRenderer = new LOI.HumanAvatar.TextureRenderer {humanAvatar, humanAvatarRenderer}
    result = textureRenderer.render()
    throw new AE.ArgumentException "Texture renderer could not render the provided avatar." unless result

    canvas = textureRenderer[canvasField]
    buffer = canvas.toBuffer 'image/png',
      compressionLevel: 9

    response.writeHead 200, 'Content-Type': 'image/png'
    response.end buffer

  catch error
    console.error error
    response.writeHead 400, 'Content-Type': 'text/txt'
    response.end error.message
