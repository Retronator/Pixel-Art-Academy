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

LOI.Assets.Sprite.remove.method (spriteId) ->
  check spriteId, Match.DocumentId

  RA.authorizeAdmin()

  LOI.Assets.Sprite.documents.remove spriteId
