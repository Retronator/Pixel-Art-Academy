AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.UniformClusters extends FM.Action
  _helper: ->
    @interface.getHelper LOI.Assets.MeshEditor.Helpers.UniformClusters

class LOI.Assets.MeshEditor.Actions.LightUniformClustersEnabled extends LOI.Assets.MeshEditor.Actions.UniformClusters
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.LightUniformClustersEnabled'
  @displayName: -> "Lights are uniform across a cluster"

  @initialize()

  active: ->
    @_helper()?.lights()

  execute: ->
    helper = @_helper()
    helper.setLights not helper.lights()

class LOI.Assets.MeshEditor.Actions.LightmapUniformClustersEnabled extends LOI.Assets.MeshEditor.Actions.UniformClusters
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.LightmapUniformClustersEnabled'
  @displayName: -> "Lightmap is uniform across a cluster"

  @initialize()

  active: ->
    @_helper()?.lightmap()

  execute: ->
    helper = @_helper()
    helper.setLightmap not helper.lightmap()
