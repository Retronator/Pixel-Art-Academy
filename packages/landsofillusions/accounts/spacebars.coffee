LOI = LandsOfIllusions

# Override account template helpers to use LOI accounts instead.
Template.registerHelper 'currentUser', ->
  LOI.user()

Template.registerHelper 'loggingIn', ->
  Meteor.loggingIn()

# Create the {{currentCharacter}} helper.
Template.registerHelper 'currentCharacter', ->
  LOI.character()
