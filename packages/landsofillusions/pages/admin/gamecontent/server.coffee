LOI = LandsOfIllusions
RA = Retronator.Accounts

WebApp.connectHandlers.use '/admin/landsofillusions/gamecontent/gamecontent.json', (request, response, next) ->
  exportedDocuments = JSON.stringify LOI.GameContent.export()

  response.writeHead 200, 'Content-Type': 'application/json'
  response.write exportedDocuments
  response.end()
