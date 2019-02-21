FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Helpers.LightDirection extends FM.Helper
  # x, y, z: coordinates of the directional light vector
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.LightDirection'
  @initialize()

  value: (newDirection) ->
    if newDirection
      @data.value _.pick newDirection, ['x', 'y', 'z']
      return

    unless direction = @data.value()
      # Load initial value from global helper.
      globalData = @interface.getComponentData @id()
      direction = globalData?.value() or x: 0, y: 0, z: 0

    THREE.Vector3.fromObject(direction).normalize()
