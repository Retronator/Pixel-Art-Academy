AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.LightSources extends FM.Action
  _helper: ->
    @interface.getHelper LOI.Assets.MeshEditor.Helpers.LightSources

class LOI.Assets.MeshEditor.Actions.LightsEnabled extends LOI.Assets.MeshEditor.Actions.LightSources
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.LightsEnabled'
  @displayName: -> "Enable geometric lights"

  @initialize()

  active: ->
    @_helper()?.lights()

  execute: ->
    helper = @_helper()
    helper.setLights not helper.lights()

class LOI.Assets.MeshEditor.Actions.LightmapEnabled extends LOI.Assets.MeshEditor.Actions.LightSources
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.LightmapEnabled'
  @displayName: -> "Enable lightmap"

  @initialize()

  active: ->
    @_helper()?.lightmap()

  execute: ->
    helper = @_helper()
    helper.setLightmap not helper.lightmap()

class LOI.Assets.MeshEditor.Actions.EnvironmentMapsEnabled extends LOI.Assets.MeshEditor.Actions.LightSources
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.EnvironmentMapsEnabled'
  @displayName: -> "Enable environment maps"

  @initialize()

  active: ->
    @_helper()?.environmentMaps()

  execute: ->
    helper = @_helper()
    helper.setEnvironmentMaps not helper.environmentMaps()

class LOI.Assets.MeshEditor.Actions.EnvironmentRendersEnabled extends LOI.Assets.MeshEditor.Actions.LightSources
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.EnvironmentRendersEnabled'
  @displayName: -> "Enable environment renders"

  @initialize()

  active: ->
    @_helper()?.environmentRenders()

  execute: ->
    helper = @_helper()
    helper.setEnvironmentRenders not helper.environmentRenders()
