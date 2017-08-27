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
    @_placeRenderer @leftBreastRenderer, 'breastCenter', 'breastLeft'
    @_placeRenderer @rightBreastRenderer, 'breastCenter', 'breastRight'
