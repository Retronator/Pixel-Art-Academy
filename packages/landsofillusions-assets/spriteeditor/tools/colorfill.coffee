AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.ColorFill extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.ColorFill'
  @displayName: -> "Color fill"

  @initialize()

  onMouseDown: (event) ->
    super arguments...

    return unless @mouseState.leftButton

    # Make sure we have paint at all.
    paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    paint =
      directColor: paintHelper.directColor()
      paletteColor: paintHelper.paletteColor()
      materialIndex: paintHelper.materialIndex()

    return [] unless paint.directColor or paint.paletteColor or paint.materialIndex?

    paint.normal = paintHelper.normal().toObject()

    spriteData = @editor().spriteData()
    layerIndex = paintHelper.layerIndex()
    layer = spriteData.layers?[layerIndex]

    xCoordinates = [@mouseState.x]

    # TODO: Get symmetry from interface data.
    # symmetryXOrigin = @options.editor().symmetryXOrigin?()

    if symmetryXOrigin?
      mirroredX = -@mouseState.x + 2 * symmetryXOrigin
      xCoordinates.push mirroredX

    layerOrigin =
      x: layer?.origin?.x or 0
      y: layer?.origin?.y or 0

    # Note: We can't be sending undefined in the method as it will
    # be converted to null, so we need an explicit boolean here.
    ignoreNormals = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).get('ignoreNormals') or false

    for xCoordinate in xCoordinates
      # Make sure we're filling inside of bounds.
      continue unless spriteData.bounds.left <= xCoordinate <= spriteData.bounds.right and spriteData.bounds.top <= @mouseState.y <= spriteData.bounds.bottom

      pixel =
        x: xCoordinate - layerOrigin.x
        y: @mouseState.y - layerOrigin.y

      for property in ['materialIndex', 'paletteColor', 'directColor']
        pixel[property] = paint[property] if paint[property]?

      pixel.normal = paint.normal if paint.normal and not ignoreNormals

      LOI.Assets.Sprite.colorFill spriteData._id, layerIndex, pixel, ignoreNormals
