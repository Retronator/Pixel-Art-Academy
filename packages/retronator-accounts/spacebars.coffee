# Override account template helpers to use LOI accounts instead.
Template.registerHelper 'currentUser', ->
  Retronator.user()

Template.registerHelper 'loggingIn', ->
  Meteor.loggingIn()

Template.registerHelper 'hasItem', (key) ->
  Retronator.user()?.hasItem key
