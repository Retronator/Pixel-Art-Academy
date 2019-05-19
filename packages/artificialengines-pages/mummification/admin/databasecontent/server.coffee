AM = Artificial.Mummification
RA = Retronator.Accounts

Archiver = require 'archiver'

WebApp.connectHandlers.use '/admin/artificial/mummification/databasecontent/databasecontent.zip', (request, response, next) ->
  query = request.query
  adminPassword = Meteor.settings.admin?.password or ''

  try
    if query.userId
      userId = CryptoJS.AES.decrypt(query.userId, adminPassword).toString CryptoJS.enc.Latin1
      RA.authorizeAdmin {userId}

    else
      throw new AE.UnauthorizedException

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

      for document in exportedDocuments when document.getDatabaseContent
        {arrayBuffer, path, lastEditTime} = document.getDatabaseContent()

        # Store file information.
        fileInformation[documentClassId].push {path, lastEditTime}

        # Place file in the archive.
        archive.append Buffer.from(arrayBuffer), name: path

    # Place file information in the archive.
    archive.append JSON.stringify(fileInformation), name: 'databasecontent.json'

    archive.finalize()

  catch error
    console.error error
    response.writeHead 400, 'Content-Type': 'text/txt'
    response.end "You do not have permission to download database content."
