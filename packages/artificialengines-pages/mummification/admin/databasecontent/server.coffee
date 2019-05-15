AM = Artificial.Mummification
RA = Retronator.Accounts

Archiver = require 'archiver'

WebApp.connectHandlers.use '/admin/artificial/mummification/databasecontent/databasecontent.zip', (request, response, next) ->
  response.writeHead 200,
    'Content-Type': 'application/zip'
    'Content-Disposition': 'attachment; filename="databasecontent.zip"'

  archive = Archiver 'zip', zlib: level: 9
  archive.pipe response
  archive.on 'end', -> response.end()

  fileInformation = {}
  databaseContent = AM.DatabaseContent.export()

  for documentClassId, exportedDocuments of databaseContent
    fileInformation[documentClassId] = []

    for document in exportedDocuments when document instanceof LandsOfIllusions.Assets.Sprite
      {arrayBuffer, path, lastEditTime} = document.getDatabaseContent()

      # Store file information.
      fileInformation[documentClassId].push {path, lastEditTime}

      # Place file in the archive.
      archive.append Buffer.from(arrayBuffer), name: path

  # Place file information in the archive.
  archive.append JSON.stringify(fileInformation), name: 'databasecontent.json'

  archive.finalize()
