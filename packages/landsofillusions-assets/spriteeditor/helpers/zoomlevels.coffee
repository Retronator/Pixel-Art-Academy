FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Helpers.ZoomLevels extends FM.Helper
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.ZoomLevels'
  @initialize()

  value: ->
    @data.value() or [12.5, 25, 50, 100, 200, 300, 400, 600, 800, 1200, 1600, 3200]
