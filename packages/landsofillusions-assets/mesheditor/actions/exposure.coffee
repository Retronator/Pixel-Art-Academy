AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class Exposure extends FM.Action
  enabled: -> @interface.activeFileId()

  execute: ->
    exposureValue = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.ExposureValue
    exposureValue exposureValue() + @change()

  change: -> 1

class LOI.Assets.MeshEditor.Actions.IncreaseExposure extends Exposure
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.IncreaseExposure'
  @displayName: -> "Increase exposure"

  @initialize()

class LOI.Assets.MeshEditor.Actions.DecreaseExposure extends Exposure
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.DecreaseExposure'
  @displayName: -> "Decrease exposure"

  @initialize()

  change: -> -1

class LOI.Assets.MeshEditor.Actions.ResetExposure extends Exposure
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ResetExposure'
  @displayName: -> "Reset exposure"

  @initialize()

  enabled: ->
    exposureValue = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.ExposureValue
    exposureValue()

  execute: ->
    exposureValue = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.ExposureValue
    exposureValue 0
