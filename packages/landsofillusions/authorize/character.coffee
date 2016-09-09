LOI = LandsOfIllusions

LOI.Authorize.characterAction = (characterId) ->
  # You need to be logged-in to perform actions with the character.
  currentUserId = Meteor.userId()
  throw new Meteor.Error 'unauthorized', "Unauthorized." unless currentUserId

  # Character must exist.
  character = LOI.Accounts.Character.documents.findOne characterId
  throw new Meteor.Error 'not-found', "Character not found." unless character

  # Admins can always perform actions.
  return if Roles.userIsInRole currentUserId, 'admin'

  # The character must belong to the logged-in user.
  throw new Meteor.Error 'unauthorized', "Unauthorized." unless character.user._id is currentUserId
