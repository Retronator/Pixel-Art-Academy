AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.Undo extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.Undo'

  constructor: (@options) ->
    super arguments...

    @caption = "Undo"
    @shortcut =
      commandOrControl: true
      key: AC.Keys.z
    
  enabled: ->
    return unless spriteData = @options.editor().spriteData()
    spriteData.historyPosition

  execute: ->
    spriteData = @options.editor().spriteData()
    return unless spriteData.historyPosition

    LOI.Assets.VisualAsset.undo 'Sprite', spriteData._id
