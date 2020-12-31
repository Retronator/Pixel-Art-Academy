RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Character.Membership.forCharacterId.publish (characterId) ->
  check characterId, Match.DocumentId

  # Only allow to subscribe for your own character.
  LOI.Authorize.characterAction characterId

  LOI.Character.Membership.documents.find 'character._id': characterId

LOI.Character.Membership.forGroupId.publish (groupId) ->
  check groupId, String

  # Only admins can see all members of a group.
  RA.authorizeAdmin()

  LOI.Character.Membership.documents.find {groupId}
