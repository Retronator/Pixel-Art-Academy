FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.ShadowsEnabled extends FM.Helper
  # boolean whether shadows are enabled
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.ShadowsEnabled'
  @initialize()

  value: (newValue) ->
    if newValue?
      @data.value newValue
      return

    @data.value()

  enabled: -> @value()
  toggle: -> @value not @value()
