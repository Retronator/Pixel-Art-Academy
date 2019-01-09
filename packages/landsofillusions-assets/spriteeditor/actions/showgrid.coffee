AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.ShowGrid extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ShowGrid'
  @displayName: -> "Show grid"
    
  @initialize()

  active: ->
    @interface.getEditorForActiveFile().grid().enabled()

  execute: ->
    @interface.getEditorForActiveFile().grid().toggle()
