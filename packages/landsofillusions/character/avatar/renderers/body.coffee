LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Body extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    @leftArmRenderer = @_createRenderer 'arms',
      regionSide: 'Left'
    
    @rightArmRenderer = @_createRenderer 'arms',
      flippedHorizontal: true
      regionSide: 'Right'
    
    @rightArmRenderer._flipHorizontal = true
    
    @torsoRenderer = @_createRenderer 'torso'
    
    @headRenderer = @_createRenderer 'head'
    
    @leftLegRenderer = @_createRenderer 'legs',
      regionSide: 'Left'
    
    @rightLegRenderer = @_createRenderer 'legs',
      flippedHorizontal: true
      regionSide: 'Right'
    
    @rightLegRenderer._flipHorizontal = true

  _placeRenderers: (side) ->
    # Place the torso.
    @_placeRenderer side, @torsoRenderer, 'navel', 'navel'

    # Place the head.
    @_placeRenderer side, @headRenderer, 'atlas', 'atlas'

    # Place the legs.
    @_placeRenderer side, @leftLegRenderer, 'acetabulum', 'acetabulumLeft'
    @_placeRenderer side, @rightLegRenderer, 'acetabulum', 'acetabulumRight'

    # Place the arms.
    @_placeRenderer side, @leftArmRenderer, 'shoulder', 'shoulderLeft'
    @_placeRenderer side, @rightArmRenderer, 'shoulder', 'shoulderRight'
  
  drawToContext: (context, options = {}) ->
    return unless @ready()

    # Draw the hair behind and in the middle first.
    context.save()

    # Depend on landmarks to update when head renderer translations change.
    @landmarks[options.side]()

    translation = _.defaults {}, @headRenderer._translation[options.side],
      x: 0
      y: 0

    context.translate translation.x, translation.y

    for renderer in @headRenderer.getHairRenderers 'HairBehind'
      @headRenderer.drawRendererToContext renderer, context, options

    for renderer in @headRenderer.getHairRenderers 'HairMiddle'
      @headRenderer.drawRendererToContext renderer, context, options

    context.restore()

    # Draw the rest as usual.
    super arguments...
