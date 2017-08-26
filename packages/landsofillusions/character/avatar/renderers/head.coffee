LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Head extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    for propertyName, property of @options.part.properties
      switch property.options.type
        when @_bodyPartType 'Neck'
          @neckRenderer = property.part.createRenderer @engineOptions
          @renderers.push @neckRenderer

        when @_bodyPartType 'HeadShape'
          @headShapeRenderer = property.part.createRenderer @engineOptions
          @renderers.push @headShapeRenderer

        when @_bodyPartType 'Eyes'
          @leftEyeRenderer = property.part.createRenderer @engineOptions
          @rightEyeRenderer = property.part.createRenderer @engineOptions, flippedHorizontal: true
          @rightEyeRenderer._flipHorizontal = true
          @renderers.push @leftEyeRenderer
          @renderers.push @rightEyeRenderer
        
  _placeRenderers: ->
    # Place the neck.
    @_placeRenderer @neckRenderer, 'atlas', 'atlas'

    # Place the head shape.
    @_placeRenderer @headShapeRenderer, 'atlas', 'atlas'

    # Place the eyes.
    @_placeRenderer @leftEyeRenderer, 'eyeCenter', 'eyeLeft'
    @_placeRenderer @rightEyeRenderer, 'eyeCenter', 'eyeRight'
