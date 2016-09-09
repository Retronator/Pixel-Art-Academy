LOI = LandsOfIllusions

# Always send current user's characters.
Meteor.publish null, ->
  LOI.Accounts.User.documents.find
    _id: @userId
  ,
    fields:
      characters: true

Meteor.publish 'LandsOfIllusions.Accounts.Character.charactersForUser', (userId) ->
  LOI.Accounts.Character.documents.find
    'user._id': userId

Meteor.publish 'character', (characterId, options) ->
  check characterId, Match.DocumentId
  check options, Match.Optional Object

  LOI.Accounts.Character.documents.find
    _id: characterId
  ,
    options
