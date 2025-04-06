RA = Retronator.Accounts
LOI = LandsOfIllusions
AM = Artificial.Mummification

LOI.Assets.Palette.allLospec.publish ->
  LOI.Assets.Palette.getPublishingDocuments().find lospecSlug: $exists: true
  
LOI.Assets.Palette.allCategorized.publish ->
  LOI.Assets.Palette.getPublishingDocuments().find category: $exists: true

LOI.Assets.Palette.forId.publish (id) ->
  check id, Match.DocumentId

  LOI.Assets.Palette.getPublishingDocuments().find id

LOI.Assets.Palette.forIds.publish (ids) ->
  check ids, [Match.DocumentId]
  
  LOI.Assets.Palette.getPublishingDocuments().find _id: $in: ids
  
LOI.Assets.Palette.forName.publish (name) ->
  check name, String
  
  LOI.Assets.Palette.getPublishingDocuments().find {name}
  
if Meteor.isServer
  LOI.Assets.Palette.all.publish ->
    RA.authorizeAdmin userId: @userId
    
    LOI.Assets.Palette.documents.find {}

if Meteor.isClient
  # Always publish the default palette.
  AM.DatabaseContent.publish null, ->
    LOI.Assets.Palette.contentDocuments.find
      name: LOI.Assets.Palette.defaultPaletteName
