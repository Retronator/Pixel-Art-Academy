AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.FlipHorizontal extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.FlipHorizontal'
  @displayName: -> "Flip horizontal"
    
  @initialize()

  enabled: -> @interface.parent.spriteData()

  execute: ->
    return unless spriteData = @interface.parent.spriteData()

    LOI.Assets.Sprite.flipHorizontal spriteData._id, 0
