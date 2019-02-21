AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Tools.Undo extends FM.Tool
  constructor: (@options) ->
    super arguments...

    @caption = "Undo"
    @shortcut =
      commandOrControl: true
      key: AC.Keys.z

  enabled: ->
    return unless audioData = @options.editor().audioData()
    audioData.historyPosition

  execute: ->
    audioData = @options.editor().audioData()
    return unless audioData.historyPosition

    LOI.Assets.Asset.undo 'Audio', audioData._id
