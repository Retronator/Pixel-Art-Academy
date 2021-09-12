AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class Exposure extends FM.Action
  enabled: -> @interface.activeFileId()

  execute: ->
    exposureValue = @interface.getHelperForActiveFile LOI.Assets.Editor.Helpers.ExposureValue
    exposureValue exposureValue() + @change()

  change: -> 1

class LOI.Assets.Editor.Actions.IncreaseExposure extends Exposure
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.IncreaseExposure'
  @displayName: -> "Increase exposure"

  @initialize()

class LOI.Assets.Editor.Actions.DecreaseExposure extends Exposure
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.DecreaseExposure'
  @displayName: -> "Decrease exposure"

  @initialize()

  change: -> -1

class LOI.Assets.Editor.Actions.ResetExposure extends Exposure
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.ResetExposure'
  @displayName: -> "Reset exposure"

  @initialize()

  enabled: ->
    return unless exposureValue = @interface.getHelperForActiveFile LOI.Assets.Editor.Helpers.ExposureValue
    exposureValue()

  execute: ->
    exposureValue = @interface.getHelperForActiveFile LOI.Assets.Editor.Helpers.ExposureValue
    exposureValue 0
