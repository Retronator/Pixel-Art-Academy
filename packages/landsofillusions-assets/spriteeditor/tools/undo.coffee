AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Undo extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super

    @name = "Undo"
    @shortcut = AC.Keys.z
    @shortcutCommandOrCtrl = true

  toolClass: ->
    return unless spriteData = @options.editor().spriteData()
    'disabled' unless spriteData.historyPosition

  method: ->
    spriteData = @options.editor().spriteData()
    return unless spriteData.historyPosition

    LOI.Assets.Sprite.undo spriteData._id, 'Sprite'
