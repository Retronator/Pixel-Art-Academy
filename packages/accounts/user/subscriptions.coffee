RA = Retronator.Accounts

# Always send current user's display name.
Meteor.publish null, ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      displayName: true

# Always send current user's items, since these also serve as our permissions.
Meteor.publish null, ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      items: true

# Current user's login services.
Meteor.publish 'Retronator.Accounts.User.loginServicesForCurrentUser', ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      loginServices: true

# Current user's registered emails.
Meteor.publish 'Retronator.Accounts.User.registeredEmailsForCurrentUser', ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      registered_emails: true

# Current user's support amount.
Meteor.publish 'Retronator.Accounts.User.supportAmountForCurrentUser', ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      supportAmount: true
