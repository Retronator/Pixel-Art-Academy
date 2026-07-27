AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Arrow extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Arrow'
  @displayName: -> "Arrow"
  
  @icon: -> "/landsofillusions/assets/editor/tools/arrow.png"
    
  @initialize()

  cursorType: -> LOI.Assets.SpriteEditor.PixelCanvas.Cursor.Types.None
