FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.ColorQuantization extends FM.Helper
  # enabled: boolean whether color quantization is enabled
  # levels: how many possible values per channel can a color have
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.ColorQuantization'
  @initialize()

  enabled: -> @data.get('enabled') ? LOI.settings.graphics.colorQuantization.value()
  setEnabled: (value) ->
    @data.set 'enabled', value

  levels: -> @data.get('levels') ? LOI.settings.graphics.colorQuantizationLevels.value()
  setLevels: (value) ->
    @data.set 'levels', value
