LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.PixelCanvas.OperationPreview
  constructor: (@pixelCanvas) ->
    @pixels = new ReactiveField []
    
    @spriteData = new ComputedField =>
      return unless assetData = @pixelCanvas.assetData()

      pixels = @pixels()
      _pixelMap = {}

      if pixels
        for pixel in pixels
          _pixelMap[pixel.x] ?= {}
          _pixelMap[pixel.x][pixel.y] = pixel

      spriteData = new LOI.Assets.Sprite
        layers: [{pixels, _pixelMap}]

      spriteData

    # Create the engine sprite.
    @paintNormalsData = @pixelCanvas.interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'paintNormals'

    @sprite = new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      visualizeNormals: @paintNormalsData.value

  drawToContext: ->
    @sprite.drawToContext arguments...
