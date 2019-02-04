FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.ShadowsEnabled extends FM.Helper
  # boolean whether shadows are enabled
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.ShadowsEnabled'
  @initialize()

  value: (newValue) ->
    if newValue?
      @data.value newValue
      return

    @data.value() ? true

  enabled: -> @value()
  toggle: -> @value not @value()
