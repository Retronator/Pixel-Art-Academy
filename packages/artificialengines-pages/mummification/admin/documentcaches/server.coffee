AM = Artificial.Mummification
RA = Retronator.Accounts

Archiver = require 'archiver'

WebApp.connectHandlers.use '/admin/artificial/mummification/documentcaches/documentcaches.zip', (request, response, next) ->
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
      'Content-Disposition': 'attachment; filename="documentcaches.zip"'

    archive = Archiver 'zip', zlib: level: 9
    archive.pipe response
    archive.on 'end', -> response.end()

    AM.DocumentCaches.export archive

  catch error
    console.error error
    response.writeHead 400, 'Content-Type': 'text/txt'
    response.end "You do not have permission to download document caches."
