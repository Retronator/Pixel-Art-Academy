FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.SmoothShadingEnabled extends FM.Helper
  # boolean whether smooth shading is enabled
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.SmoothShadingEnabled'
  @initialize()

  value: (newValue) ->
    if newValue?
      @data.value newValue
      return

    @data.value()

  enabled: -> @value()
  toggle: -> @value not @value()
