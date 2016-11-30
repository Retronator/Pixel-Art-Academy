LOI = LandsOfIllusions

LOI.Authorize.characterAction = (characterId) ->
  RS = Retronator.Store
  
  # You need to be logged-in to perform actions with the character.
  user = Retronator.user()
  throw new AE.UnauthorizedException "You must be logged in to perform actions with a character." unless user

  # Character must exist.
  character = LOI.Character.documents.findOne characterId
  throw new AE.ArgumentException "Character not found." unless character

  # Admins can always perform actions.
  return if user.hasItem RS.Items.CatalogKeys.Retronator.Admin

  # The character must belong to the logged-in user.
  throw new AE.UnauthorizedException "The character must belong to you." unless character.user._id is user._id
