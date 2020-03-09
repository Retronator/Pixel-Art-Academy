FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.PBREnabled extends FM.Helper
  # boolean whether physically based rendering is enabled
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.PBREnabled'
  @initialize()

  value: (newValue) ->
    if newValue?
      @data.value newValue
      return

    @data.value()

  enabled: -> @value()
  toggle: -> @value not @value()
