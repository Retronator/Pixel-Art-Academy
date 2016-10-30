LOI = LandsOfIllusions
RA = Retronator.Accounts

# Automatically publish current user's game state.
Meteor.publish null, ->
  LOI.GameState.documents.find
    'user._id': @userId
