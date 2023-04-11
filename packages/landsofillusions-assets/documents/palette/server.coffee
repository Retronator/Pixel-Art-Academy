AE = Artificial.Everywhere
LOI = LandsOfIllusions

{PNG} = require 'pngjs'

WebApp.connectHandlers.use LOI.Assets.Palette.imageUrl, (request, response, next) ->
  query = request.query
  
  if query.name
    palette = LOI.Assets.Palette.documents.findOne name: query.name
    
  else if query.lospec
    palette = LOI.Assets.Palette.documents.findOne lospecSlug: query.lospec

  throw new AE.ArgumentException "Palette not found." unless palette
  
  imageData = palette.getPreviewImage().getFullImageData()

  # Create the PNG.
  png = new PNG
    width: imageData.width
    height: imageData.height

  # Copy data from engine sprite to the PNG.
  png.data.set imageData.data

  # Return the PNG.
  buffer = PNG.sync.write png

  response.writeHead 200, 'Content-Type': 'image/png'
  response.end buffer
