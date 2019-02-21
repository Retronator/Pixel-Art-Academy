AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.FlipHorizontal extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.FlipHorizontal'
  @displayName: -> "Flip horizontal"
    
  @initialize()

  execute: ->
    LOI.Assets.Sprite.flipHorizontal @asset()._id, 0
