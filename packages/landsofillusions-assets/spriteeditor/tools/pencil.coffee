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

    paint.normal = @paintHelper.normal().toObject()

    for coordinate in coordinates
      pixel = _.clone coordinate

      for property in ['normal', 'materialIndex', 'paletteColor', 'directColor']
        pixel[property] = paint[property] if paint[property]?
                
      pixel

  applyPixels: (spriteData, layerIndex, relativePixels, strokeStarted) ->
    # See if we're only painting normals.
    paintNormals = @data.get 'paintNormals'
    ignoreNormals = @data.get 'ignoreNormals'

    changedPixels = _.filter relativePixels, (pixel) =>
      existingPixel = spriteData.getPixelForLayerAtCoordinates layerIndex, pixel.x, pixel.y
  
      if paintNormals and existingPixel
        # Get the color from the existing pixel.
        for property in ['materialIndex', 'paletteColor', 'directColor']
          pixel[property] = existingPixel[property] if existingPixel[property]?

      if ignoreNormals and existingPixel
        # Get the normal from the existing pixel.
        pixel.normal = existingPixel.normal if existingPixel.normal?
      
      # We need to add this pixel unless one just like it is already there.
      not EJSON.equals existingPixel, pixel

    return unless changedPixels.length

    LOI.Assets.Sprite.addPixels spriteData._id, layerIndex, changedPixels, not strokeStarted

    # Register that we've processed the start of the stroke.
    @startOfStrokeProcessed()
