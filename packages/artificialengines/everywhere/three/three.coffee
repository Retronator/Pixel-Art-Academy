# Export into global namespace.
THREE = require 'three'
window.THREE = THREE if Meteor.isClient

# Disable color management to preserve compatibility with palettes that use sRGB color triplets.
THREE.ColorManagement.enabled = false
