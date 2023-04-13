AM = Artificial.Mummification
RA = Retronator.Accounts

Archiver = require 'archiver'
PNG = Npm.require('pngjs').PNG

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

    AM.DatabaseContent.export archive, query.append

  catch error
    console.error error
    response.writeHead 400, 'Content-Type': 'text/txt'
    response.end "You do not have permission to download database content."

WebApp.connectHandlers.use '/admin/artificial/mummification/databasecontent/preview.png', (request, response, next) ->
  documentClass = AM.Document.getClassForId request.query.documentClassId
  document = documentClass.documents.findOne request.query.documentId
  
  {arrayBuffer} = document.getDatabaseContent()
  
  response.writeHead 200, 'Content-Type': 'image/png'
  response.end Buffer.from(arrayBuffer)
