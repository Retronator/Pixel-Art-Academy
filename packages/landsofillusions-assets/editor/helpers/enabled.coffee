FM = FataMorgana
LOI = LandsOfIllusions

# Parent class for helpers that hold a boolean value.
class LOI.Assets.Editor.Helpers.Enabled extends FM.Helper
  value: (newValue) ->
    if newValue?
      @data.value newValue
      return

    @data.value() ? @default()

  enabled: -> @value()
  toggle: -> @value not @value()
  default: -> false
