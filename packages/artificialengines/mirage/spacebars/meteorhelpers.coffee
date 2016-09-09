Template.registerHelper 'settings', (key) ->
  Meteor.settings.public[key]
