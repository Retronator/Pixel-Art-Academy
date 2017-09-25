AE = Artificial.Everywhere

# Add the user helper. We allow sending it a user ID to support calling this from subscriptions.
Retronator.user = (options) ->
  if options?.userId isnt undefined
    userId = options?.userId

  else
    userId = Meteor.userId()

  Retronator.Accounts.User.documents.findOne userId, options

# User helper that throws an exception if user is not logged in.
Retronator.requireUser = (options) ->
  user = Retronator.user options

  throw new AE.UnauthorizedException "You must be logged in to perform this operation." unless user

  user
