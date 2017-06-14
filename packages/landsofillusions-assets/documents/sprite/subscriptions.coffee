RA = Retronator.Accounts
LOI = LandsOfIllusions

# Subscription to a specific sprite.
LOI.Assets.Sprite.forId.publish (id) ->
  check id, Match.DocumentId

  LOI.Assets.Sprite.documents.find id

LOI.Assets.Sprite.all.publish ->
  # Only admins (and later sprite editors) can see all the sprite.
  RA.authorizeAdmin userId: @userId

  LOI.Assets.Sprite.documents.find()
