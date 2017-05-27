LOI = LandsOfIllusions
RA = Retronator.Accounts

# Always send current user's characters field on the user document.
userCharacterFieldCursor = (userId) ->
  RA.User.documents.find
    _id: userId
  ,
    fields:
      'characters': true
  
Meteor.publish null, -> userCharacterFieldCursor @userId
      
# Also create an explicit subscription so we can know when it is ready.
Meteor.publish 'Retronator.Accounts.User.charactersForCurrentUser', -> userCharacterFieldCursor @userId

Meteor.publish 'LandsOfIllusions.Character.character', (characterId) ->
  LOI.Character.documents.find characterId

Meteor.publish 'LandsOfIllusions.Character.charactersForCurrentUser', ->
  LOI.Character.documents.find
    'user._id': @userId

Meteor.publish 'LandsOfIllusions.Character.charactersForUser', (userId) ->
  LOI.Character.documents.find
    'user._id': userId
  ,
    fields:
      user: 0
