AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.ShowLandmarks extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ShowLandmarks'
  @displayName: -> "Show landmarks"
    
  @initialize()

  landmarksHelper: ->
    @interface.getHelperForActiveFile LOI.Assets.SpriteEditor.Helpers.Landmarks

  active: ->
    @landmarksHelper().enabled()

  execute: ->
    @landmarksHelper().toggle()
