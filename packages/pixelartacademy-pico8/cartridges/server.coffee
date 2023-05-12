AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PNG = Npm.require('pngjs').PNG
Request = request

WebApp.connectHandlers.use '/pico8/cartridge.png', (request, response, next) ->
  query = request.query

  try
    game = PAA.Pico8.Game.documents.findOne query.gameId
    throw new AE.ArgumentException "Game not found." unless game

    project = PAA.Practice.Project.documents.findOne query.projectId
    throw new AE.ArgumentException "Project not found." unless project

  catch error
    console.error error
    response.writeHead 400, 'Content-Type': 'text/txt'
    response.end error.message
    return

  cartridgeUrl = game.cartridge.url

  # Create a local URL if needed.
  cartridgeUrl = Meteor.absoluteUrl cartridgeUrl unless cartridgeUrl.indexOf('http') > -1

  # Get the cartridge url
  cartridgeResponse = Request.getSync cartridgeUrl, encoding: null
  png = PNG.sync.read cartridgeResponse.body

  pico8Palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.pico8

  try
    game.replaceCartridgeImageAssets png, project, pico8Palette

  catch error
    console.error "Rendering PICO-8 cartridge failed.", error, query

  buffer = PNG.sync.write png

  response.writeHead 200, 'Content-Type': 'image/png'
  response.end buffer
