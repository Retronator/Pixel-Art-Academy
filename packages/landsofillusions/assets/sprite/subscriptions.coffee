LOI = LandsOfIllusions

# Subscription to a specific sprite.
LOI.Assets.Sprite.forId.publish (id) ->
  check id, Match.DocumentId

  LOI.Assets.Sprite.documents.find id
