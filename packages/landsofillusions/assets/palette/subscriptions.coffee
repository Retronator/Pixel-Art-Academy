LOI = LandsOfIllusions

# Always publish the default palette.
Meteor.publish null, ->
  LOI.Assets.Palette.documents.find
    name: LOI.Assets.Palette.defaultPaletteName

# Subscription to a specific palette.
Meteor.publish 'LandsOfIllusions.Assets.Palette', (paletteIdOrName, options) ->
  check paletteIdOrName, Match.OneOf Match.DocumentId, String
  check options, Match.Optional Object

  if Match.test paletteIdOrName, Match.DocumentId
    query = _id: paletteIdOrName

  else
    query = name: paletteIdOrName

  LOI.Assets.Palette.documents.findOne query, options
