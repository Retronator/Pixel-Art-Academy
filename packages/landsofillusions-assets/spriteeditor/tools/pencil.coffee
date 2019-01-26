AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Pencil extends LOI.Assets.SpriteEditor.Tools.Stroke
  # paintNormals: boolean whether only normals are being painted
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Pencil'
  @displayName: -> "Pencil"

  @initialize()

  createPixelsFromCoordinates: (coordinates) ->
    # Make sure we have paint at all.
    paint =
      directColor: @paintHelper.directColor()
      paletteColor: @paintHelper.paletteColor()
      materialIndex: @paintHelper.materialIndex()
    
    return [] unless paint.directColor or paint.paletteColor or paint.materialIndex?

    paint.normal = @paintHelper.normal().clone()

    for coordinate in coordinates
      pixel = _.clone coordinate

      for property in ['normal', 'materialIndex', 'paletteColor', 'directColor']
        pixel[property] = paint[property] if paint[property]?
                
      pixel

  processPixelsOnServer: (spriteData, layerIndex, pixels) ->
    for pixel in pixels
      # See if we're only painting normals.
      paintNormals = @data.get 'paintNormals'

      existingPixel = _.find spriteData.layers?[layerIndex]?.pixels, (searchPixel) -> pixel.x is searchPixel.x and pixel.y is searchPixel.y
  
      if paintNormals and existingPixel
        # Get the color from the existing pixel.
        for property in ['materialIndex', 'paletteColor', 'directColor']
          pixel[property] = existingPixel[property] if existingPixel[property]?
      
      # Do we even need to add this pixel? See if one just like it is already there.
      exactMatch = LOI.Assets.Sprite.documents.findOne
        _id: spriteData._id
        "layers.#{layerIndex}.pixels": pixel

      continue if exactMatch
          
      LOI.Assets.Sprite.addPixel spriteData._id, layerIndex, pixel
