AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Sprite.allGeneric.publish ->
  # Only admins (and later sprite editors) can see all the sprite.
  RA.authorizeAdmin userId: @userId or null

  # We only return sprite names when subscribing to all so that we can list them.
  LOI.Assets.Sprite.documents.find
    authors:
      $exists: false
  ,
    fields:
      name: 1

LOI.Assets.Sprite.forMeshId.publish (meshId) ->
  check meshId, Match.DocumentId

  @autorun ->
    mesh = LOI.Assets.Mesh.documents.findOne meshId
    throw new AE.ArgumentException "Mesh does not exist." unless mesh

    # Nothing to return if there are no camera angles.
    return unless mesh.cameraAngles

    spriteIds = (cameraAngle.sprite?._id for cameraAngle in mesh.cameraAngles)
    _.pull spriteIds, undefined
    
    LOI.Assets.Sprite.documents.find _id: $in: spriteIds

LOI.Assets.Sprite.forCharacterPartTemplatesOfTypes.publish (types) ->
  check types, [String]

  # Note: We don't run inside an autorun to save server resources. Reactivity here is not important.
  templates = LOI.Character.Part.Template._forTypes(types, {}, @userId).fetch()
  spriteIds = _.flatten (template.spriteIds for template in templates)

  LOI.Assets.Sprite.documents.find _id: $in: spriteIds
