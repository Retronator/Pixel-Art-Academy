FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Helpers.LightDirection extends FM.Helper
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.LightDirection'
  @initialize()

  value: (newDirection) ->
    if newDirection
      @data.value _.pick newDirection, ['x', 'y', 'z']
      return

    direction = @data.value() or x: 0, y: 0, z: -1
    THREE.Vector3.fromObject(direction).normalize()
