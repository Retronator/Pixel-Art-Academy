AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.FlipHorizontal extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super arguments...

    @name = "Flip horizontal"

  method: ->
    return unless spriteData = @options.editor().spriteData()

    LOI.Assets.Sprite.flipHorizontal spriteData._id, 0
