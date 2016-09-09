LOI = LandsOfIllusions

# Confirms that the user can play the game.
LOI.Authorize.player = ->
  throw new Meteor.Error 'unauthorized', "Unauthorized." unless Roles.userIsInRole Meteor.userId(), 'create-character'

# Confirms administrator privileges.
LOI.Authorize.admin = ->
  throw new Meteor.Error 'unauthorized', "Unauthorized." unless Roles.userIsInRole Meteor.userId(), 'admin'
