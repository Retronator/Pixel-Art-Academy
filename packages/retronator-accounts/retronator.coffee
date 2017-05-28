# Add the user helper.
Retronator.user = (options) ->
  Retronator.Accounts.User.documents.findOne Meteor.userId(), options

# User helper that throws an exception if user is not logged in.
Retronator.requireUser = (options) ->
  user = Retronator.user()
  throw new AE.UnauthorizedException "You must be logged in to perform this operation." unless user

  user
