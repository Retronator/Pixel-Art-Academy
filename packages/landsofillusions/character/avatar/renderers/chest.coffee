LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Chest extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    @chestShapeRenderer = @_createRenderer 'shape'

    @leftBreastRenderer = @_createRenderer 'breasts',
      regionSide: 'Left'

    @rightBreastRenderer = @_createRenderer 'breasts',
      flippedHorizontal: true
      regionSide: 'Right'

    @rightBreastRenderer._flipHorizontal = true

  _placeRenderers: (side) ->
    # Place the chest shape.
    @_placeRenderer side, @chestShapeRenderer, 'vertebraT9', 'vertebraT9'
    @_placeRenderer side, @leftBreastRenderer, 'breastCenter', 'breastLeft'
    @_placeRenderer side, @rightBreastRenderer, 'breastCenter', 'breastRight'
