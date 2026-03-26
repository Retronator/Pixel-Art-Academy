AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Get a specific project.
PAA.Practice.Project.forId.publish (projectId) ->
  check projectId, Match.DocumentId

  PAA.Practice.Project.getPublishingDocuments().find projectId

# Get all the assets for a project.
PAA.Practice.Project.assetsForProjectId.publish (projectId) ->
  check projectId, Match.DocumentId
  
  project = PAA.Practice.Project.documents.findOne projectId
  bitmapIds = (asset.bitmapId for asset in project.assets when asset.bitmapId)
  
  LOI.Assets.Bitmap.getPublishingDocuments().find _id: $in: bitmapIds
