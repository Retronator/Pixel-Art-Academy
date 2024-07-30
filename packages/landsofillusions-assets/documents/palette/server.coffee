AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

{PNG} = require 'pngjs'

LOI.Assets.Palette.addIfNeeded = (palette) ->
  if existingPalette = LOI.Assets.Palette.documents.findOne name: palette.name
    changed = false

    # Check that the palette's keys are the same as in the database (other keys can be present, such as lastEditTime).
    for key, value of palette
      unless EJSON.equals value, existingPalette[key]
        changed = true
        break
        
    return unless changed
  
  LOI.Assets.Palette.documents.upsert {name: palette.name}, {$set: palette}

# Export all palette documents.
AM.DatabaseContent.addToExport ->
  LOI.Assets.Palette.documents.fetch()
  
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
