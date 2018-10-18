AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Sprite.clear.method (spriteId) ->
  check spriteId, Match.DocumentId

  RA.authorizeAdmin()

  # Delete all the pixels.
  LOI.Assets.Sprite.documents.update spriteId,
    $unset:
      layers: true
      bounds: true
