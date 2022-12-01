RA = Retronator.Accounts
LOI = LandsOfIllusions

# Always publish the default palette.
Meteor.publish null, ->
  LOI.Assets.Palette.documents.find
    name: LOI.Assets.Palette.defaultPaletteName

LOI.Assets.Palette.all.publish ->
  RA.authorizeAdmin userId: @userId

  LOI.Assets.Palette.documents.find {}
  
LOI.Assets.Palette.allLospec.publish ->
  LOI.Assets.Palette.documents.find lospecSlug: $exists: true
  
LOI.Assets.Palette.forId.publish (id) ->
  check id, Match.DocumentId

  LOI.Assets.Palette.documents.find id
  
LOI.Assets.Palette.forIds.publish (ids) ->
  check ids, [Match.DocumentId]
  
  LOI.Assets.Palette.documents.find _id: $in: ids

LOI.Assets.Palette.forName.publish (name) ->
  check name, String

  LOI.Assets.Palette.documents.find name: name
