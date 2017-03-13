LOI = LandsOfIllusions
RA = Retronator.Accounts

Meteor.publish LOI.GameState.forCurrentUser, ->
  return unless @userId
  
  LOI.GameState.documents.find
    'user._id': @userId
