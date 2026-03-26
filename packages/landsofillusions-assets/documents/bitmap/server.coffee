AE = Artificial.Everywhere
LOI = LandsOfIllusions

{PNG} = require 'pngjs'

WebApp.connectHandlers.use LOI.Assets.Bitmap.documentUrl(), (request, response, next) ->
  query = request.query
  
  bitmap = LOI.Assets.Bitmap.documents.findOne query.id
  throw new AE.ArgumentException "Bitmap not found." unless bitmap
  
  response.writeHead 200, 'Content-type': 'application/json'
  response.write JSON.stringify bitmap
  response.end()

WebApp.connectHandlers.use LOI.Assets.Bitmap.imageUrl(), (request, response, next) ->
  query = request.query
  
  bitmap = LOI.Assets.Bitmap.documents.findOne query.id
  throw new AE.ArgumentException "Bitmap not found." unless bitmap

  engineBitmap = new LOI.Assets.Engine.PixelImage.Bitmap
    asset: -> bitmap

  unless bitmapImageData = engineBitmap.getImageData()
    # There are no pixels in the bitmap yet, so just return an empty 1px image.
    bitmapImageData = new AM.ReadableCanvas(1, 1).getFullImageData()

  # Create the PNG.
  png = new PNG
    width: bitmapImageData.width
    height: bitmapImageData.height

  # Copy data from engine bitmap to the PNG.
  png.data.set bitmapImageData.data

  # Return the PNG.
  buffer = PNG.sync.write png

  response.writeHead 200, 'Content-Type': 'image/png'
  response.end buffer
