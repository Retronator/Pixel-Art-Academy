AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.RecomputeMesh extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.RecomputeMesh'
  @displayName: -> "Recompute mesh"

  @initialize()

  execute: ->
    mesh = @asset()
    object.recompute() for object in mesh.objects.getAll()
