# Export into global namespace.
Ammo = require('./build/ammo.js')()
window.Ammo = Ammo if Meteor.isClient
