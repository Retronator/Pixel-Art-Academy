LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Breasts extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: (options) ->
    @topShapeRenderer = @_createRenderer 'topShape'
    @bottomShapeRenderer = @_createRenderer 'bottomShape'
    @nippleShapeRenderer = @_createRenderer 'nippleShape'

  _placeRenderers: ->
    # Place the chest shape.
    @_placeRenderer @topShapeRenderer, 'breastCenter', 'breastCenter'
    @_placeRenderer @bottomShapeRenderer, 'breastCenter', 'breastCenter'

    # Place the nipple.
    properties = @options.part.properties

    @_placeRenderer @nippleShapeRenderer, 'breastCenter', 'breastCenter',
      offsetX: properties.nippleOffsetX.options.dataLocation() or 0
      offsetY: properties.nippleOffsetY.options.dataLocation() or 0
      skipAddingLandmarks: true
