LOI = LandsOfIllusions

# Always send current user's display name.
Meteor.publish null, ->
  LOI.Accounts.User.documents.find
    _id: @userId
  ,
    fields:
      displayName: true
