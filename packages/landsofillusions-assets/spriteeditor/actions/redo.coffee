AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.Redo extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.Redo'

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
    return unless spriteData = @options.editor().spriteData()
    spriteData.historyPosition < spriteData.history?.length

  execute: ->
    spriteData = @options.editor().spriteData()
    return unless spriteData.historyPosition < spriteData.history?.length

    LOI.Assets.VisualAsset.redo 'Sprite', spriteData._id
