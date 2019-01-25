AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Mesh.insert.method ->
  RA.authorizeAdmin()

  LOI.Assets.Mesh.documents.insert {}

LOI.Assets.Mesh.update.method (meshId, update, options) ->
  check meshId, Match.DocumentId
  check update, Object
  check options, Match.Optional Object

  RA.authorizeAdmin()

  LOI.Assets.Mesh.documents.update meshId, update, options

LOI.Assets.Mesh.clear.method (meshId) ->
  check meshId, Match.DocumentId

  RA.authorizeAdmin()

  # Delete all the camera angles.
  LOI.Assets.Mesh.documents.update meshId,
    $unset:
      cameraAngles: true

LOI.Assets.Mesh.remove.method (meshId) ->
  check meshId, Match.DocumentId

  RA.authorizeAdmin()

  LOI.Assets.Mesh.documents.remove meshId

LOI.Assets.Mesh.duplicate.method (meshId) ->
  check meshId, Match.DocumentId

  RA.authorizeAdmin()

  mesh = LOI.Assets.Mesh.documents.findOne meshId
  throw new AE.ArgumentException "Mesh does not exist." unless mesh

  # Move desired properties to a plain object.
  duplicate = {}

  for own key, value of mesh when not (key in ['name', '_id', '_schema'])
    duplicate[key] = value

  LOI.Assets.Mesh.documents.insert duplicate
  
LOI.Assets.Mesh.updateCameraAngle.method (meshId, index, cameraAngleUpdate) ->
  check meshId, Match.DocumentId
  check index, Match.Integer
  check cameraAngleUpdate,
    name: Match.Optional String
    picturePlaneDistance: Match.OptionalOrNull Number
    picturePlaneOffset: Match.Optional
      x: Number
      y: Number
    pixelSize: Match.OptionalOrNull Number
    position: Match.Optional vectorPattern
    target: Match.Optional vectorPattern
    up: Match.Optional vectorPattern
    sprite: Match.Optional
      _id: Match.DocumentId

  RA.authorizeAdmin()

  mesh = LOI.Assets.VisualAsset._requireAsset meshId, LOI.Assets.Mesh
  
  # If we don't have camera angles at all, we create it as an array
  # so that sets will create index entries not object properties.
  unless mesh.cameraAngles
    LOI.Assets.Mesh.documents.update meshId,
      $set:
        cameraAngles: []

  # Get existing camera angle or create a new entry.
  cameraAngle = mesh.cameraAngles?[index] or {}

  # Update the fields that are set. (We don't use extend because that introduces null values.)
  if cameraAngleUpdate
    for key, value of cameraAngleUpdate when value isnt undefined
      if value
        cameraAngle[key] = value

      else
        delete cameraAngle[key]

  LOI.Assets.Mesh.documents.update meshId,
    $set:
      "cameraAngles.#{index}": cameraAngle

vectorPattern =
  x: Number
  y: Number
  z: Number
