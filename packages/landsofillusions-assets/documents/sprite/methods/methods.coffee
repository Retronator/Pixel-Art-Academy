AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Sprite.insert.method ->
  RA.authorizeAdmin()

  LOI.Assets.Sprite.documents.insert {}

LOI.Assets.Sprite.update.method (spriteId, update, options) ->
  check spriteId, Match.DocumentId
  check update, Object
  check options, Match.Optional Object

  RA.authorizeAdmin()

  LOI.Assets.Sprite.documents.update spriteId, update, options

LOI.Assets.Sprite.clear.method (spriteId) ->
  check spriteId, Match.DocumentId

  RA.authorizeAdmin()

  # Delete all the pixels.
  LOI.Assets.Sprite.documents.update spriteId,
    $unset:
      layers: true
      bounds: true

LOI.Assets.Sprite.remove.method (spriteId) ->
  check spriteId, Match.DocumentId

  RA.authorizeAdmin()

  LOI.Assets.Sprite.documents.remove spriteId

LOI.Assets.Sprite.duplicate.method (spriteId) ->
  check spriteId, Match.DocumentId

  RA.authorizeAdmin()

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  # Move desired properties to a plain object.
  duplicate = {}

  for own key, value of sprite when not (key in ['name', '_id', '_schema'])
    duplicate[key] = value

  LOI.Assets.Sprite.documents.insert duplicate
