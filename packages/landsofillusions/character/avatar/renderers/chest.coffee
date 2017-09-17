LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Chest extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    @chestShapeRenderer = @_createRenderer 'shape'
    @leftBreastRenderer = @_createRenderer 'breasts'
    @rightBreastRenderer = @_createRenderer 'breasts', flippedHorizontal: true
    @rightBreastRenderer._flipHorizontal = true

  _placeRenderers: ->
    # Place the chest shape.
    @_placeRenderer @chestShapeRenderer, 'xiphoid', 'xiphoid'

    # Place the breasts.
    properties = @options.part.properties

    breastsOffset =
      offsetX: properties.breastsOffsetX.options.dataLocation() or 0
      offsetY: properties.breastsOffsetY.options.dataLocation() or 0

    @_placeRenderer @leftBreastRenderer, 'breastCenter', 'breastLeft', breastsOffset
    @_placeRenderer @rightBreastRenderer, 'breastCenter', 'breastRight', breastsOffset
