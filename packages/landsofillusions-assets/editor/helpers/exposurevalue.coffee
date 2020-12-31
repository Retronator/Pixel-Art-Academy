FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Helpers.ExposureValue extends FM.Helper
  # exposure value used for tone mapping
  @id: -> 'LandsOfIllusions.Assets.Editor.Helpers.ExposureValue'
  @initialize()

  value: (newValue) ->
    if newValue?
      @data.value newValue
      return

    @data.value() or 0

  exposure: ->
    2 ** @value()
