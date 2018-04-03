LOI = LandsOfIllusions

LOI.Character.forId.publish (characterId) ->
  check characterId, Match.DocumentId

  LOI.Character.documents.find characterId,
    fields:
      # Don't send character's email.
      contactEmail: false

LOI.Character.forCurrentUser.publish ->
  LOI.Character.documents.find
    'user._id': @userId

LOI.Character.activatedForCurrentUser.publish ->
  LOI.Character.documents.find
    'user._id': @userId
    activated: true
