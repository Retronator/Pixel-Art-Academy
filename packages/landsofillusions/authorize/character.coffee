AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Authorize.characterAction = (characterId) ->
  RS = Retronator.Store
  
  # You need to be logged-in to perform actions with the character.
  user = Retronator.requireUser()

  # Character must exist.
  character = LOI.Character.documents.findOne characterId
  throw new AE.ArgumentException "Character not found." unless character

  # The character must belong to the logged-in user.
  throw new AE.UnauthorizedException "The character must belong to you." unless character.user._id is user._id
