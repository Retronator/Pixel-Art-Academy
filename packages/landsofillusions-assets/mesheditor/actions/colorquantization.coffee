AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ColorQuantization extends FM.Action
  _helper: ->
    @interface.getHelper LOI.Assets.MeshEditor.Helpers.ColorQuantization

class LOI.Assets.MeshEditor.Actions.ColorQuantizationEnabled extends LOI.Assets.MeshEditor.Actions.ColorQuantization
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ColorQuantizationEnabled'
  @displayName: -> "Color quantization"

  @initialize()

  active: ->
    @_helper()?.enabled()

  execute: ->
    helper = @_helper()
    helper.setEnabled not helper.enabled()

class LOI.Assets.MeshEditor.Actions.IncreaseQuantizationLevels extends LOI.Assets.MeshEditor.Actions.ColorQuantization
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.IncreaseQuantizationLevels'
  @displayName: -> "Increase quantization levels"

  @initialize()

  execute: ->
    helper = @_helper()
    helper.setLevels helper.levels() + 1

class LOI.Assets.MeshEditor.Actions.DecreaseQuantizationLevels extends LOI.Assets.MeshEditor.Actions.ColorQuantization
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.DecreaseQuantizationLevels'
  @displayName: -> "Decrease quantization levels"

  @initialize()

  execute: ->
    helper = @_helper()
    helper.setLevels helper.levels() - 1

class LOI.Assets.MeshEditor.Actions.ResetQuantizationLevels extends LOI.Assets.MeshEditor.Actions.ColorQuantization
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ResetQuantizationLevels'
  @displayName: -> "Reset quantization levels"

  @initialize()

  execute: ->
    helper = @_helper()
    helper.setLevels null
