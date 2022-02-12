AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.LightShadowsEnabled extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.LightShadowsEnabled'
  @displayName: -> "Enable geometric light shadows"

  @initialize()

  active: ->
    @_helper()?.enabled()

  execute: ->
    @_helper().toggle()

  _helper: ->
    @interface.getHelper LOI.Assets.MeshEditor.Helpers.LightShadowsEnabled
