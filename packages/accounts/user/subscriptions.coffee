RA = Retronator.Accounts

# Always send current user's display name.
Meteor.publish null, ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      displayName: true

# Current user's login services.
Meteor.publish 'Retronator.Accounts.User.loginServicesForCurrentUser', ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      loginServices: true

# Current user's contact email.
Meteor.publish 'Retronator.Accounts.User.contactEmailForCurrentUser', ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      contactEmail: true

# Current user's registered emails.
Meteor.publish 'Retronator.Accounts.User.registeredEmailsForCurrentUser', ->
  RA.User.documents.find
    _id: @userId
  ,
    fields:
      registered_emails: true
