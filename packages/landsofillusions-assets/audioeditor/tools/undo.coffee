AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Tools.Undo extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super arguments...

    @name = "Undo"
    @shortcut = AC.Keys.z
    @shortcutCommandOrCtrl = true

  toolClass: ->
    return unless audioData = @options.editor().audioData()
    'enabled' if audioData.historyPosition

  method: ->
    audioData = @options.editor().audioData()
    return unless audioData.historyPosition

    LOI.Assets.Asset.undo 'Audio', audioData._id
