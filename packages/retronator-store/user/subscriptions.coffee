RA = Retronator.Accounts

# Always send current user's items, since these also serve as our permissions.
Meteor.publish null, ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      items: true

# Current user's support amount.
Meteor.publish RA.User.supportAmountForCurrentUser, ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      supportAmount: true

# Current user's store data.
Meteor.publish RA.User.storeDataForCurrentUser, ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      store: true
