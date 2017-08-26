LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Body extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    for propertyName, property of @options.part.properties
      switch property.options.type
        when @_bodyPartType 'Head'
          @headRenderer = property.part.createRenderer @engineOptions
          @renderers.push @headRenderer

        when @_bodyPartType 'Torso'
          @torsoRenderer = property.part.createRenderer @engineOptions
          @renderers.push @torsoRenderer

        when @_bodyPartType 'Legs'
          @leftLegRenderer = property.part.createRenderer @engineOptions
          @rightLegRenderer = property.part.createRenderer @engineOptions, flippedHorizontal: true
          @rightLegRenderer._flipHorizontal = true
          @renderers.push @leftLegRenderer
          @renderers.push @rightLegRenderer

        when @_bodyPartType 'Arms'
          @leftArmRenderer = property.part.createRenderer @engineOptions
          @rightArmRenderer = property.part.createRenderer @engineOptions, flippedHorizontal: true
          @rightArmRenderer._flipHorizontal = true
          @renderers.push @leftArmRenderer
          @renderers.push @rightArmRenderer

  _placeRenderers: ->
    # Place the torso.
    @_placeRenderer @torsoRenderer, 'navel', 'navel'

    # Place the head.
    @_placeRenderer @headRenderer, 'suprasternalNotch', 'suprasternalNotch'

    # Place the legs.
    @_placeRenderer @leftLegRenderer, 'acetabulum', 'acetabulumLeft'
    @_placeRenderer @rightLegRenderer, 'acetabulum', 'acetabulumRight'

    # Place the arms.
    @_placeRenderer @leftArmRenderer, 'shoulder', 'shoulderLeft'
    @_placeRenderer @rightArmRenderer, 'shoulder', 'shoulderRight'
