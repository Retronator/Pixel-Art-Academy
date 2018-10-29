LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Head extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    # We create hair-behind renderers separately, so they won't render together with the rest of the head.
    @hairBehindRenderers = for part in @options.part.properties.hairBehind.parts()
      part.createRenderer()

    # Create the rest of the renderers normally.
    @neckRenderer = @_createRenderer 'neck'
    @headShapeRenderer = @_createRenderer 'shape'
    @leftEyeRenderer = @_createRenderer 'eyes'
    @rightEyeRenderer = @_createRenderer 'eyes', flippedHorizontal: true
    @rightEyeRenderer._flipHorizontal = true
    @hairRenderers = @_createRenderer 'hair'
    @facialHairRenderers = @_createRenderer 'facialHair'

  _placeRenderers: ->
    # Place the neck.
    @_placeRenderer @neckRenderer, 'atlas', 'atlas'

    # Place the head shape.
    @_placeRenderer @headShapeRenderer, 'atlas', 'atlas'

    # Place the eyes.
    @_placeRenderer @leftEyeRenderer, 'eyeCenter', 'eyeLeft'
    @_placeRenderer @rightEyeRenderer, 'eyeCenter', 'eyeRight'

    # Place the hair.
    @_placeRenderer hairRenderer, 'forehead', 'forehead' for hairRenderer in @hairBehindRenderers
    @_placeRenderer hairRenderer, 'forehead', 'forehead' for hairRenderer in @hairRenderers

    # Place the facial hair.
    @_placeRenderer facialHairRenderer, 'mouth', 'mouth' for facialHairRenderer in @facialHairRenderers

  drawToContext: (context, options = {}) ->
    return unless @ready()

    # If we're drawing only the head also draw the hair behind.
    if options.rootPart is @options.part
      context.save()

      # Depend on landmarks to update when renderer translations change.
      @landmarks()

      translation = _.defaults {}, @_translation,
        x: 0
        y: 0
  
      context.translate translation.x, translation.y
  
      for renderer in @hairBehindRenderers
        @drawRendererToContext renderer, context, options
  
      context.restore()

    # Draw the rest as usual.
    super arguments...
