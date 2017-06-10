LOI = LandsOfIllusions

# Always publish the default palette.
Meteor.publish null, ->
  LOI.Assets.Palette.documents.find
    name: LOI.Assets.Palette.defaultPaletteName

# Subscription to a specific palette.
LOI.Assets.Palette.forId.publish (id) ->
  check id, Match.DocumentId

  LOI.Assets.Palette.documents.find id

LOI.Assets.Palette.forName.publish (name) ->
  check name, String

  LOI.Assets.Palette.documents.find name: name
