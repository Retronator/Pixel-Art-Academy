# Export into global namespace.
THREE = require 'three'
window.THREE = THREE if Meteor.isClient
