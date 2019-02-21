AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Tools.Redo extends FM.Tool
  constructor: (@options) ->
    super arguments...

    @caption = "Redo"

    if AM.ShortcutHelper.currentPlatformConvention is AM.ShortcutHelper.PlatformConventions.MacOS
      @shortcut =
        command: true
        shift: true
        key: AC.Keys.z

    else
      @shortcut =
        control: true
        key: AC.Keys.y

  enabled: ->
    return unless audioData = @options.editor().audioData()
    audioData.historyPosition < audioData.history?.length

  execute: ->
  method: ->
    audioData = @options.editor().audioData()
    return unless audioData.historyPosition < audioData.history?.length

    LOI.Assets.Asset.redo 'Audio', audioData._id
