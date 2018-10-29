AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Tools.Redo extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super arguments...

    @name = "Redo"
    @shortcut = AC.Keys.z
    @shortcutCommandOrCtrl = true
    @shortcutShift = true

  toolClass: ->
    return unless audioData = @options.editor().audioData()
    'enabled' if audioData.historyPosition < audioData.history?.length

  method: ->
    audioData = @options.editor().audioData()
    return unless audioData.historyPosition < audioData.history?.length

    LOI.Assets.Asset.redo 'Audio', audioData._id
