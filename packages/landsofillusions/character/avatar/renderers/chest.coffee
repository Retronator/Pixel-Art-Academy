LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Chest extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    for propertyName, property of @options.part.properties
      switch property.options.type
        when @_bodyPartType 'ChestShape'
          @chestShapeRenderer = property.part.createRenderer @engineOptions
          @renderers.push @chestShapeRenderer

        when @_bodyPartType 'Breasts'
          @leftBreastRenderer = property.part.createRenderer @engineOptions
          @rightBreastRenderer = property.part.createRenderer @engineOptions, flippedHorizontal: true
          @rightBreastRenderer._flipHorizontal = true
          @renderers.push @leftBreastRenderer
          @renderers.push @rightBreastRenderer

  _placeRenderers: ->
    # Place the chest shape.
    @_placeRenderer @chestShapeRenderer, 'xiphoid', 'xiphoid'

    # Place the breasts.
    @_placeRenderer @leftBreastRenderer, 'breastCenter', 'breastLeft'
    @_placeRenderer @rightBreastRenderer, 'breastCenter', 'breastRight'
