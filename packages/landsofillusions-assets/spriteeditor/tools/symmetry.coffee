AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Symmetry extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super

    @name = "Symmetry"
    @shortcut = AC.Keys.s

  toolClass: ->
    'enabled' if @options.editor().symmetryXOrigin()?

  method: ->
    symmetryXOriginField = @options.editor().symmetryXOrigin
    symmetryXOriginField if symmetryXOriginField()? then null else 0
