AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.Symmetry extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.Symmetry'

  constructor: (@options) ->
    super arguments...

    @caption = "Symmetry"
    @shortcut = key: AC.Keys.s

  active: -> @options.editor().symmetryXOrigin()?

  execute: ->
    symmetryXOriginField = @options.editor().symmetryXOrigin
    symmetryXOriginField if symmetryXOriginField()? then null else 0
