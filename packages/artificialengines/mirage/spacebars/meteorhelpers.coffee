Template.registerHelper 'settings', (key) ->
  _.nestedProperty Meteor.settings.public, key
