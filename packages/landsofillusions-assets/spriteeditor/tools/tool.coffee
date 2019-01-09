AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Tool extends FM.Tool
  @icon: -> "/landsofillusions/assets/spriteeditor/tools/#{_.kebabCase @displayName()}.png"

  constructor: ->
    super arguments...

    @editor = new ComputedField =>
      @interface.getEditorForActiveFile()
  
  onMouseMove: (event) ->
    return unless pixelCoordinate = @editor().mouse().pixelCoordinate()
    
    @mouseState.x = pixelCoordinate.x
    @mouseState.y = pixelCoordinate.y
