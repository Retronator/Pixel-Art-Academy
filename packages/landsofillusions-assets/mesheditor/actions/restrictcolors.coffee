AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.RestrictColors extends FM.Action
  _helper: ->
    @interface.getHelper LOI.Assets.MeshEditor.Helpers.RestrictColors

class LOI.Assets.MeshEditor.Actions.RestrictRampColors extends LOI.Assets.MeshEditor.Actions.RestrictColors
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.RestrictRampColors'
  @displayName: -> "Restrict colors to palette ramps"

  @initialize()

  active: ->
    @_helper()?.ramps()

  execute: ->
    helper = @_helper()
    helper.setRamps not helper.ramps()

class LOI.Assets.MeshEditor.Actions.RestrictRampShades extends LOI.Assets.MeshEditor.Actions.RestrictColors
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.RestrictRampShades'
  @displayName: -> "Restrict colors to palette shades"

  @initialize()

  enabled: -> @_helper().ramps()

  active: ->
    @_helper()?.shades()

  execute: ->
    helper = @_helper()
    helper.setShades not helper.shades()
