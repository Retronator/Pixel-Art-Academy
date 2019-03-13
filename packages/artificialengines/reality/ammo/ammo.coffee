# Export into global namespace.
Ammo = require('ammo.js')()
window.Ammo = Ammo if Meteor.isClient
