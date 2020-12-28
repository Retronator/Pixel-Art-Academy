LOI = LandsOfIllusions
RA = Retronator.Accounts

LOI.Character.all.publish ->
  RA.authorizeAdmin()

  LOI.Character.documents.find()

LOI.Character.allLive.publish ->
  RA.authorizeAdmin()

  LOI.Character.documents.find
    user: $ne: null

LOI.Character.forId.publish (characterId) ->
  check characterId, Match.DocumentId

  LOI.Character.documents.find characterId,
    fields:
      # Don't send user data.
      user: false
      archivedUser: false

      # Don't send character's email.
      contactEmail: false

LOI.Character.forCurrentUser.publish ->
  LOI.Character.documents.find
    'user._id': @userId
