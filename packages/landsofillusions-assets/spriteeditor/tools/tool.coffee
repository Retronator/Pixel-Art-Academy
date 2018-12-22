AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Tool extends FM.Tool
  onMouseMove: (event) ->
    return unless pixelCoordinate = @options.editor().pixelCanvas().mouse().pixelCoordinate()
    
    @mouseState.x = pixelCoordinate.x
    @mouseState.y = pixelCoordinate.y
