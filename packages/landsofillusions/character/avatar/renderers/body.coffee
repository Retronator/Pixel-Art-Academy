LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Body extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    @leftArmRenderer = @_createRenderer 'arms'
    @rightArmRenderer = @_createRenderer 'arms', flippedHorizontal: true
    @rightArmRenderer._flipHorizontal = true
    @torsoRenderer = @_createRenderer 'torso'
    @headRenderer = @_createRenderer 'head'
    @leftLegRenderer = @_createRenderer 'legs'
    @rightLegRenderer = @_createRenderer 'legs', flippedHorizontal: true
    @rightLegRenderer._flipHorizontal = true

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
  
  drawToContext: (context, options = {}) ->
    return unless @ready()

    # Draw the hair behind first.
    context.save()

    # Depend on landmarks to update when head renderer translations change.
    @landmarks()

    translation = _.defaults {}, @headRenderer._translation,
      x: 0
      y: 0

    context.translate translation.x, translation.y

    for renderer in @headRenderer.hairBehindRenderers
      @headRenderer.drawRendererToContext renderer, context, options

    context.restore()

    # Draw the rest as usual.
    super arguments...
