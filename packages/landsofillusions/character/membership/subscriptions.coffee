LOI = LandsOfIllusions

LOI.Character.Membership.forCharacterId.publish (characterId) ->
  check characterId, Match.DocumentId

  # Only allow to subscribe for your own character.
  LOI.Authorize.characterAction characterId

  LOI.Character.Membership.documents.find 'character._id': characterId
