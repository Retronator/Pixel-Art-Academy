AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.FlipHorizontal extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.FlipHorizontal'

  constructor: (@options) ->
    super arguments...

    @caption = "Flip horizontal"

  enabled: ->
    @options.editor().spriteData()

  execute: ->
    return unless spriteData = @options.editor().spriteData()

    LOI.Assets.Sprite.flipHorizontal spriteData._id, 0
