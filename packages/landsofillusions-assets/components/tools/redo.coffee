AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.Components.Tools.Redo extends LandsOfIllusions.Assets.Components.Tools.Tool
  constructor: ->
    super arguments...

    @name = "Redo"
    @shortcut = AC.Keys.z
    @shortcutCommandOrCtrl = true
    @shortcutShift = true

  extraToolClasses: ->
    return unless spriteData = @options.editor().spriteData()
    'enabled' if spriteData.historyPosition < spriteData.history?.length

  method: ->
    spriteData = @options.editor().spriteData()
    return unless spriteData.historyPosition < spriteData.history?.length

    LOI.Assets.VisualAsset.redo 'Sprite', spriteData._id
