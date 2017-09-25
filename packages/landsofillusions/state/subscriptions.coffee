LOI = LandsOfIllusions
RA = Retronator.Accounts

LOI.GameState.forCurrentUser.publish ->
  return unless @userId
  
  LOI.GameState.documents.find
    'user._id': @userId

LOI.GameState.forCharacter.publish (characterId) ->
  check characterId, Match.DocumentId
  return unless @userId

  # Make sure the character belongs to the user.
  character = LOI.Character.documents.findOne characterId

  unless character?.user._id is @userId
    throw new AE.UnauthorizedException "The character does not belong to the logged in user."

  LOI.GameState.documents.find
    'character._id': characterId
