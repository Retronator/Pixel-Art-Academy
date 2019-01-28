FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Helpers.LightDirection extends FM.Helper
  # x, y, z: coordinates of the directional light vector
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.LightDirection'
  @initialize()

  constructor: ->
    super arguments...

    if @fileId and not @data.value()
      # Load initial value from global helper.
      globalData = @interface.getComponentData @id()
      @data.value globalData.value()

  value: (newDirection) ->
    if newDirection
      @data.value _.pick newDirection, ['x', 'y', 'z']
      return

    direction = @data.value() or x: 0, y: 0, z: -1
    THREE.Vector3.fromObject(direction).normalize()
