LOI = LandsOfIllusions

# Always publish the default palette.
Meteor.publish null, ->
  LOI.Assets.Palette.documents.find
    name: LOI.Assets.Palette.defaultPaletteName

# Subscription to a specific palette.
Meteor.publish 'palette', (paletteId, options) ->
  check paletteId, Match.DocumentId
  check options, Match.Optional Object

  LOI.Assets.Palette.documents.find
    _id: paletteId
  ,
    options
