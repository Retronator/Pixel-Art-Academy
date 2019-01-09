AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.ColorPicker extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.ColorPicker'
  @displayName: -> "Color picker"

  @initialize()

  onMouseDown: (event) ->
    super arguments...

    @pickColor()

  onMouseMove: (event) ->
    super arguments...

    @pickColor()

  pickColor: ->
    return unless @mouseState.leftButton

    editor = @interface.getEditorForActiveFile()
    spriteData = editor.spriteData()
    
    paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    # Go over all pixels to find the one we want.
    for layer in spriteData.layers
      for pixel in layer.pixels
        if pixel.x is @mouseState.x and pixel.y is @mouseState.y
          if pixel.paletteColor
            paintHelper.setPaletteColor pixel.paletteColor
            
          else if pixel.directColor
            paintHelper.setDirectColor pixel.directColor
            
          else if pixel.materialIndex?
            paintHelper.setMaterialIndex pixel.materialIndex

          if pixel.normal
            paintHelper.setNormal pixel.normal

          return
