LOI = LandsOfIllusions

LOI.Character.Group.forCharacterId.publish (characterId) ->
  check characterId, Match.DocumentId

  # Only allow to subscribe to your own character.
  LOI.Authorize.characterAction characterId

  LOI.Character.Group.documents.find 'character._id': characterId
