AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Practice.Pages.Admin.Projects.insertPublicProject.method (project, assets) ->
  check project, Object
  check assets, Object
  RA.authorizeAdmin()

  console.log "Creating public project …"

  PAA.Practice.Project.documents.insert project
  console.log "Inserted project with name #{project.name}."
  
  for asset in project.assets
    if asset.bitmapId
      bitmap = assets[asset.bitmapId]
      LOI.Assets.Bitmap.documents.insert bitmap
      console.log "Inserted bitmap with name #{bitmap.name}."
