FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Helpers.ZoomLevels extends FM.Helper
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.ZoomLevels'
  @initialize()

  value: ->
    (super arguments...) or [12.5, 25, 50, 100 * 2 / 3, 100, 200, 300, 400, 600, 800, 1200, 1600, 3200]
