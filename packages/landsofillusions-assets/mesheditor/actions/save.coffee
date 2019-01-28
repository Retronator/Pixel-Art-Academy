AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.Save extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.Save'
  @displayName: -> "Save"

  @initialize()

  enabled: ->
    @asset()?.dirty()

  execute: ->
    @asset().save()
