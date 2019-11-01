AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.Resize extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.Resize'
  @displayName: -> "Resize"
    
  @initialize()

  execute: ->
    @interface.displayDialog
      contentComponentId: LOI.Assets.SpriteEditor.ResizeDialog.id()
