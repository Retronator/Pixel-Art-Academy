AM = Artificial.Mirage
AMu = Artificial.Mummification
AS = Artificial.Spectrum
LOI = LandsOfIllusions
RA = Retronator.Accounts

Archiver = require 'archiver'

textureWidth = 1024
textureHeight = 128
textureMagnification = 4
regionPadding = 1
sideOffset = 100
characterSafeSize = 100

WebApp.connectHandlers.use '/admin/landsofillusions/characters/assets/creatureassets.zip', (request, response, next) ->
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
      'Content-Disposition': 'attachment; filename="creatureassets.zip"'

    archive = Archiver 'zip', zlib: level: 9
    archive.pipe response
    archive.on 'end', -> response.end()

    # Export texture regions.
    archive.append EJSON.stringify(createTextureRegions(), indent: true), name: "textureregions.json"

    # Export textures.
    {layoutCanvas, characterCanvas} = createTextures()

    buffer = layoutCanvas.toBuffer 'image/png', compressionLevel: 9
    archive.append Buffer.from(buffer), name: "layouttexture.png"

    buffer = characterCanvas.toBuffer 'image/png', compressionLevel: 9
    archive.append Buffer.from(buffer), name: "previewtexture.png"

    # Export rig regions.
    defaultBodyPart = LOI.Character.Part.Types.Avatar.Body.create
      dataLocation: new AMu.Hierarchy.Location
        rootField: AMu.Hierarchy.create
          templateClass: LOI.Character.Part.Template
          type: LOI.Character.Part.Types.Avatar.Body.options.type
          load: => null

    bodyRenderer = defaultBodyPart.createRenderer
      useDatabaseSprites: true

    for side, key of LOI.Engine.RenderingSides.Keys
      landmarks = bodyRenderer.landmarks[key]()
      archive.append EJSON.stringify(createRigRegion(key, landmarks), indent: true), name: "rigregions/#{_.toLower key}.json"

    # Complete exporting.
    archive.finalize()

    console.log "Creature assets export done!"

  catch error
    console.error error
    response.writeHead 400, 'Content-Type': 'text/txt'
    response.end "You do not have permission to download Creature assets."

createTextureRegions = ->
  meta =
    size:
      w: textureWidth * textureMagnification
      h: textureHeight * textureMagnification
      padding: regionPadding * textureMagnification

  frames = []

  for side, sideIndex in LOI.HumanAvatar.TextureRenderer.textureSides
    textureOffset = sideOffset * sideIndex

    for regionName, region of LOI.HumanAvatar.Regions when region.options.bounds
      frames.push
        filename: "#{region.options.id} #{_.titleCase side}.png"
        frame:
          x: (region.options.bounds.x() + textureOffset) * textureMagnification
          y: region.options.bounds.y() * textureMagnification
          w: region.options.bounds.width() * textureMagnification
          h: region.options.bounds.height() * textureMagnification

  {meta, frames}

createTextures = ->
  layoutCanvas = new AM.Canvas textureWidth * textureMagnification, textureHeight * textureMagnification
  layoutContext = layoutCanvas.context

  layoutContext.fillStyle = "grey"

  for side, sideIndex in LOI.HumanAvatar.TextureRenderer.textureSides
    textureOffset = sideOffset * sideIndex

    for regionName, region of LOI.HumanAvatar.Regions when region.options.bounds
      x = (region.options.bounds.x() + textureOffset + regionPadding) * textureMagnification
      y = (region.options.bounds.y() + regionPadding) * textureMagnification
      width = (region.options.bounds.width() - regionPadding * 2) * textureMagnification
      height = (region.options.bounds.height() - regionPadding * 2) * textureMagnification

      layoutContext.fillRect x, y, width, height

  # Render a character for preview purposes.
  characterCanvas = new AM.Canvas textureWidth, textureHeight
  characterContext = characterCanvas.context

  character = LOI.Character.documents.findOne debugName: 'Ariya'
  humanAvatar = new LOI.Character.Avatar character

  humanAvatarRenderer = new LOI.Character.Avatar.Renderers.HumanAvatar
    humanAvatar: humanAvatar
    renderTexture: true
    useDatabaseSprites: true
  ,
    true

  characterContext.setTransform 1, 0, 0, 1, 0, 0
  characterContext.save()

  for side, sideIndex in LOI.HumanAvatar.TextureRenderer.textureSides
    humanAvatarRenderer.drawToContext characterContext,
      rootPart: humanAvatarRenderer.options.part
      textureOffset: sideOffset * sideIndex
      side: side
      lightDirection: new THREE.Vector3(0, -1, -1).normalize()

    characterContext.restore()

  characterCanvas = AS.Hqx.scale characterCanvas, 4, AS.Hqx.Modes.NoBlending, false

  layoutContext.drawImage characterCanvas, 0, 0

  {layoutCanvas, characterCanvas}

createRigRegion = (side, landmarks) ->
  header =
    canvasWidth: characterSafeSize
    canvasHeight: characterSafeSize

  regions = []

  # Export regions from front to back so they will appear correctly ordered in Creature.
  orderedRegions = _.reverse LOI.Character.Avatar.Renderers.HumanAvatar.regionsOrder[side]

  for region in orderedRegions
    origin = region.options.origin
    landmarkPosition = _.find landmarks, (landmark) -> landmark.name is origin.landmark and landmark.regionId is region.id

    unless landmarkPosition
      # Relax the search conditions since a region might not have a default
      # shape and will not have any landmarks of its own (e.g. SexOrgan region).
      landmarkPosition = _.find landmarks, (landmark) -> landmark.name is origin.landmark

    regions.push
      name: "#{region.options.id} #{_.titleCase side}"
      x: landmarkPosition.x - origin.x + characterSafeSize / 2
      y: landmarkPosition.y - origin.y + characterSafeSize / 2
      width: region.options.bounds.width()
      height: region.options.bounds.height()

  {header, regions}
