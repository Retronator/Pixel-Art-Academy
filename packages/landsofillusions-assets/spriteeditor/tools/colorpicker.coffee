AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.ColorPicker extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.ColorPicker'

  constructor: ->
    super arguments...

    @name = "Color picker"
    @shortcut = 
      key: AC.Keys.i
      holdKey: AC.Keys.alt
    @icon = '/landsofillusions/assets/editor/icons/color-picker.png'

  onMouseDown: (event) ->
    super arguments...

    @pickColor()

  onMouseMove: (event) ->
    super arguments...

    @pickColor()

  pickColor: ->
    return unless @mouseState.leftButton

    spriteData = @options.editor().spriteData()

    # Go over all pixels to find the one we want.
    for layer in spriteData.layers
      for pixel in layer.pixels
        if pixel.x is @mouseState.x and pixel.y is @mouseState.y
          if pixel.paletteColor
            @options.editor().palette().setColor pixel.paletteColor.ramp, pixel.paletteColor.shade
            
          else if pixel.materialIndex?
            @options.editor().materials().setIndex pixel.materialIndex

          if pixel.normal
            @options.editor().shadingSphere().setNormal pixel.normal

          return
