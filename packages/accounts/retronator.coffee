# Add the user helper.
Retronator.user = (options) ->
  Retronator.Accounts.User.documents.findOne Meteor.userId(), options
