LOI = LandsOfIllusions
RA = Retronator.Accounts

Meteor.publish 'LandsOfIllusions.GameState.forCurrentUser', ->
  LOI.GameState.documents.find
    'user._id': @userId
