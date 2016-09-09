unless Retronator
  class Retronator

# Add the user helper.
Retronator.user = ->
  Retronator.Accounts.User.documents.findOne Meteor.userId()
