AM = Artificial.Mirage
AMu = Artificial.Mummification
AS = Artificial.Spectrum
LOI = LandsOfIllusions
RA = Retronator.Accounts

Archiver = require 'archiver'

textureWidth = LOI.HumanAvatar.TextureRenderer.textureWidth
textureHeight = LOI.HumanAvatar.TextureRenderer.textureHeight
textureMagnification = LOI.HumanAvatar.TextureRenderer.textureMagnification
regionPadding = 1
sideWidth = LOI.HumanAvatar.TextureRenderer.sideWidth
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

    # Laod default character.
    defaultCharacter = LOI.Character.documents.findOne debugName: 'Default'
    defaultHumanAvatar = new LOI.Character.Avatar defaultCharacter

    # Export textures.
    {layoutCanvas, characterCanvas, landmarksCanvas} = createTextures defaultHumanAvatar

    buffer = layoutCanvas.toBuffer 'image/png', compressionLevel: 9
    archive.append Buffer.from(buffer), name: "layouttexture.png"

    buffer = characterCanvas.toBuffer 'image/png', compressionLevel: 9
    archive.append Buffer.from(buffer), name: "previewtexture.png"

    buffer = landmarksCanvas.toBuffer 'image/png', compressionLevel: 9
    archive.append Buffer.from(buffer), name: "landmarkstexture.png"

    # Export rig regions.
    defaultHumanAvatarRenderer = new LOI.Character.Avatar.Renderers.HumanAvatar
      humanAvatar: defaultHumanAvatar
      useDatabaseSprites: true
    ,
      true

    for side, key of LOI.Engine.RenderingSides.Keys
      landmarks = defaultHumanAvatarRenderer.bodyRenderer.landmarks[key]()
      archive.append EJSON.stringify(createRigRegion(key, landmarks), indent: true), name: "rigregions/#{_.toLower key}.json"

    # Export rig templates.
    for side, key of LOI.Engine.RenderingSides.Keys
      landmarks = defaultHumanAvatarRenderer.bodyRenderer.landmarks[key]()
      archive.append EJSON.stringify(createRigTemplate(key, landmarks), indent: true), name: "rigtemplates/#{_.toLower key}.creaRig"

    # Complete exporting.
    archive.finalize()

    console.log "Creature assets export done!"

    defaultHumanAvatarRenderer.destroy()
    defaultHumanAvatar.destroy()

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
    textureOffset = sideWidth * sideIndex

    for regionName, region of LOI.HumanAvatar.Regions when region.options.bounds
      frames.push
        filename: "#{region.options.id} #{_.titleCase side}.png"
        frame:
          x: (region.options.bounds.x() + textureOffset) * textureMagnification
          y: region.options.bounds.y() * textureMagnification
          w: region.options.bounds.width() * textureMagnification
          h: region.options.bounds.height() * textureMagnification

  {meta, frames}

createTextures = (humanAvatar) ->
  layoutCanvas = new AM.Canvas textureWidth * textureMagnification, textureHeight * textureMagnification
  layoutContext = layoutCanvas.context

  layoutContext.fillStyle = "white"
  layoutContext.globalAlpha = 0.3

  for side, sideIndex in LOI.HumanAvatar.TextureRenderer.textureSides
    textureOffset = sideWidth * sideIndex

    for regionName, region of LOI.HumanAvatar.Regions when region.options.bounds
      x = (region.options.bounds.x() + textureOffset + regionPadding) * textureMagnification
      y = (region.options.bounds.y() + regionPadding) * textureMagnification
      width = (region.options.bounds.width() - regionPadding * 2) * textureMagnification
      height = (region.options.bounds.height() - regionPadding * 2) * textureMagnification

      layoutContext.fillRect x, y, width, height

  layoutContext.globalAlpha = 1

  # Render a character for preview purposes.
  characterCanvas = new AM.Canvas textureWidth, textureHeight
  characterContext = characterCanvas.context

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
      textureOffset: sideWidth * sideIndex
      side: side
      lightDirection: new THREE.Vector3(0, -1, -1).normalize()

    characterContext.restore()

  characterCanvas = AS.Hqx.scale characterCanvas, 4, AS.Hqx.Modes.NoBlending, false

  layoutContext.drawImage characterCanvas, 0, 0

  # Render the landmarks for rigging purposes.
  landmarksCanvas = new AM.Canvas textureWidth * textureMagnification, textureHeight * textureMagnification
  landmarksContext = landmarksCanvas.context

  # Start with a very faint image of the character.
  landmarksContext.globalAlpha = 0.2
  landmarksContext.drawImage characterCanvas, 0, 0
  landmarksContext.globalAlpha = 1

  # Draw landmarks.
  landmarksContext.fillStyle = 'white'
  drawnSkeletonLandmarks = ['vertebra', 'atlas', 'mouth', 'headTop', 'shoulder', 'elbow', 'wrist', 'fingertip', 'acetabulum',
    'knee', 'ankle', 'toeTip', 'hairBack', 'hairFront']

  for side, sideIndex in LOI.HumanAvatar.TextureRenderer.textureSides
    landmarksContext.setTransform textureMagnification, 0, 0, textureMagnification, sideWidth * sideIndex * textureMagnification, 0

    for landmark in humanAvatarRenderer.bodyRenderer.landmarks[side]() when landmark.regionId
      # See if we should draw this landmark.
      drawLandmark = false
      for drawnSkeletonLandmark in drawnSkeletonLandmarks
        if _.startsWith landmark.name, drawnSkeletonLandmark
          drawLandmark = true
          break

      continue unless drawLandmark

      # Draw a square for the landmark.
      landmarksContext.fillRect landmark.x + 0.25, landmark.y + 0.25, 0.5, 0.5

    landmarksContext.restore()

  layoutContext.drawImage landmarksCanvas, 0, 0

  {layoutCanvas, characterCanvas, landmarksCanvas}

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

    horizontalOffset = if region.options.flipHorizontal then region.options.bounds.width() - origin.x else origin.x

    regions.push
      name: "#{region.options.id} #{_.titleCase side}"
      x: landmarkPosition.x - horizontalOffset + characterSafeSize / 2
      y: landmarkPosition.y - origin.y + characterSafeSize / 2
      width: region.options.bounds.width()
      height: region.options.bounds.height()

  {header, regions}

humanSkeleton =
  landmark: 'vertebraL3'
  children:
    "Lumbar Spine":
      landmark: 'vertebraS1'
      part: 'Torso'
      children:
        "Left Acetabulum":
          landmark: 'acetabulumLeft'
          part: 'Torso'
          children:
            "Left Upper Leg":
              landmark: 'kneeLeft'
              children:
                "Left Lower Leg":
                  landmark: 'ankleLeft'
                  children:
                    "Left Foot":
                      landmark: 'toeTip'
                      regionId: 'LeftFoot'
        "Right Acetabulum":
          landmark: 'acetabulumRight'
          part: 'Torso'
          children:
            "Right Upper Leg":
              landmark: 'kneeRight'
              children:
                "Right Lower Leg":
                  landmark: 'ankleRight'
                  children:
                    "Right Foot":
                      landmark: 'toeTip'
                      regionId: 'RightFoot'
        "Thoracic Spine Bottom":
          landmark: 'vertebraT9'
          parentLandmark: 'vertebraL3'
          part: 'Torso'
          children:
            "Thoracic Spine Top":
              landmark: 'vertebraT1'
              part: 'Torso'
              children:
                Neck:
                  landmark: 'atlas'
                  part: 'Torso'
                  children:
                    Head:
                      landmark: 'headTop'
                      children:
                        "Hair Left 1":
                          landmark: 'hairLeft2'
                          parentLandmark: 'hairLeft1'
                          part: 'Hair'
                          children:
                            "Hair Left 2":
                              landmark: 'hairLeft3'
                              part: 'Hair'
                              children:
                                "Hair Left 3":
                                  landmark: 'hairLeft4'
                                  part: 'Hair'
                        "Hair Right 1":
                          landmark: 'hairRight2'
                          parentLandmark: 'hairRight1'
                          part: 'Hair'
                          children:
                            "Hair Right 2":
                              landmark: 'hairRight3'
                              part: 'Hair'
                              children:
                                "Hair Right 3":
                                  landmark: 'hairRight4'
                                  part: 'Hair'
                        "Hair Back 1":
                          landmark: 'hairBack2'
                          parentLandmark: 'hairBack1'
                          part: 'Hair'
                          children:
                            "Hair Back 2":
                              landmark: 'hairBack3'
                              part: 'Hair'
                              children:
                                "Hair Back 3":
                                  landmark: 'hairBack4'
                                  part: 'Hair'
                                  children:
                                    "Hair Back 4":
                                      landmark: 'hairBack5'
                                      part: 'Hair'
                "Left Shoulder":
                  landmark: 'shoulderLeft'
                  part: 'Torso'
                  children:
                    "Left Upper Arm":
                      landmark: 'elbowLeft'
                      children:
                        "Left Lower Arm":
                          landmark: 'wrist'
                          regionId: 'LeftHand'
                          children:
                            "Left Hand":
                              landmark: 'fingertip'
                              regionId: 'LeftHand'
                "Right Shoulder":
                  landmark: 'shoulderRight'
                  part: 'Torso'
                  children:
                    "Right Upper Arm":
                      landmark: 'elbowRight'
                      children:
                        "Right Lower Arm":
                          landmark: 'wrist'
                          regionId: 'RightHand'
                          children:
                            "Right Hand":
                              landmark: 'fingertip'
                              regionId: 'RightHand'
            "Clothes Top L 1":
              landmark: 'clothesTopL2'
              parentLandmark: 'clothesTopL1'
              part: 'Clothes'
              children:
                "Clothes Top L 2":
                  landmark: 'clothesTopL3'
                  part: 'Clothes'
                  children:
                    "Clothes Top L 3":
                      landmark: 'clothesTopL4'
                      part: 'Clothes'
            "Clothes Top R 1":
              landmark: 'clothesTopR2'
              parentLandmark: 'clothesTopR1'
              part: 'Clothes'
              children:
                "Clothes Top R 2":
                  landmark: 'clothesTopR3'
                  part: 'Clothes'
                  children:
                    "Clothes Top R 3":
                      landmark: 'clothesTopR4'
                      part: 'Clothes'
        "Clothes Bottom L 1":
          landmark: 'clothesBottomL2'
          parentLandmark: 'clothesBottomL1'
          part: 'Clothes'
          children:
            "Clothes Bottom L 2":
              landmark: 'clothesBottomL3'
              part: 'Clothes'
              children:
                "Clothes Bottom L 3":
                  landmark: 'clothesBottomL4'
                  part: 'Clothes'
                  children:
                    "Clothes Bottom L 4":
                      landmark: 'clothesBottomL5'
                      part: 'Clothes'
        "Clothes Bottom R 1":
          landmark: 'clothesBottomR2'
          parentLandmark: 'clothesBottomR1'
          part: 'Clothes'
          children:
            "Clothes Bottom R 2":
              landmark: 'clothesBottomR3'
              part: 'Clothes'
              children:
                "Clothes Bottom R 3":
                  landmark: 'clothesBottomR4'
                  part: 'Clothes'
                  children:
                    "Clothes Bottom R 4":
                      landmark: 'clothesBottomR5'
                      part: 'Clothes'
                      
createRigTemplate = (side, landmarks) ->
  boneBodyMap = {}
  allBones = {}
  nextBoneId = 1

  addBones = (parent, boneName, data, transform) ->
    if parent
      # Add bone spanning from child to parent landmark.
      transformInverse = new THREE.Matrix4().copy(transform).invert()

      getLandmarkVector = (name, regionId) ->
        if regionId
          landmark = _.find landmarks, (landmark) -> landmark.name is name and landmark.regionId is regionId

        else
          landmark = _.find landmarks, (landmark) -> landmark.name is name

        # Some landmarks might not be present for the current side.
        return unless landmark

        # Note: Creature coordinate space has positive Y pointing upwards.
        vector = new THREE.Vector3 landmark.x, -landmark.y, 0

        # Translate to local space.
        vector.applyMatrix4 transformInverse

        vector

      startVector = getLandmarkVector data.parentLandmark or parent.landmark, parent.regionId
      endVector = getLandmarkVector data.landmark, data.regionId

      # Skip bones that don't have their landmarks present.
      return unless startVector and endVector

      # Assign an ID to the bone.
      data.id = nextBoneId
      nextBoneId++

      boneData =
        id: data.id
        name: boneName
        localRestStartPt: [startVector.x, startVector.y]
        localRestEndPt: [endVector.x, endVector.y]
        restParentMat: _.clone transform.elements
        children: []

      allBones[data.id] = boneData

      boneBodyMap[boneName] = data.part or boneName

    # Traverse the children if the hierarchy continues.
    return unless data.children

    # Calculate the new transform.
    if parent
      rotationDifference = new THREE.Vector3().subVectors endVector, startVector
      childrenTransform = new THREE.Matrix4().makeRotationZ Math.atan2 rotationDifference.y, rotationDifference.x

      rootVector = getLandmarkVector parent.landmark, parent.regionId
      translationDifference = new THREE.Vector3().subVectors endVector, rootVector
      childrenTransform.setPosition translationDifference

      childrenTransform.premultiply transform

    else
      childrenTransform = transform

    for boneName, child of data.children
      addBones data, boneName, child, childrenTransform
      boneData?.children.push child.id if child.id

  addBones null, null, humanSkeleton, new THREE.Matrix4

  bone_body_map: boneBodyMap
  all_bones: allBones
