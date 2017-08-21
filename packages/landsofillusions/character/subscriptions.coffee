LOI = LandsOfIllusions

LOI.Character.forId.publish (characterId) ->
  LOI.Character.documents.find characterId

LOI.Character.forCurrentUser.publish ->
  LOI.Character.documents.find
    'user._id': @userId

LOI.Character.activatedForCurrentUser.publish ->
  LOI.Character.documents.find
    'user._id': @userId
    activated: true
