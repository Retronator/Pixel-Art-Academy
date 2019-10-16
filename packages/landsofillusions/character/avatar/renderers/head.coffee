LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Head extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    rendererOptions = @_cloneRendererOptions()

    # We create (facial) hair renderer separately so we can draw front and back parts in correct order.
    hairParts = [@options.part.properties.facialHair.parts()..., @options.part.properties.hair.parts()...]
    @hairRenderers = for part in hairParts
      part.createRenderer rendererOptions

    # Create the rest of the renderers normally.
    @headShapeRenderer = @_createRenderer 'shape'
    @leftEyeRenderer = @_createRenderer 'eyes'
    @rightEyeRenderer = @_createRenderer 'eyes', flippedHorizontal: true
    @rightEyeRenderer._flipHorizontal = true

  _placeRenderers: (side) ->
    # Place the head shape.
    @_placeRenderer side, @headShapeRenderer, 'atlas', 'atlas'

    # Place the eyes.
    @_placeRenderer side, @leftEyeRenderer, 'eyeCenter', 'eyeLeft'
    @_placeRenderer side, @rightEyeRenderer, 'eyeCenter', 'eyeRight'

    # Place the hair.
    for hairRenderer in @hairRenderers
      @_placeRenderer side, hairRenderer, 'headCenter', 'headCenter'
      @_placeRenderer side, hairRenderer, 'mouth', 'mouth'

    # Since facial hair renderers don't use the headCenter landmark but mouth instead, we need to pass the
    # headCenter-to-mouth offset down into the renderer so that it can position the sprite correctly when rendering to
    # the texture region as that one only has the headCenter landmark.
    headLandmarks = @headShapeRenderer.landmarks[side]()
    mouthLandmark = _.find headLandmarks, (landmark) => landmark.name is 'mouth'
    headCenterLandmark = _.find headLandmarks, (landmark) => landmark.name is 'headCenter'

    if mouthLandmark and headCenterLandmark
      regionOriginOffset =
        x: mouthLandmark.x - headCenterLandmark.x
        y: mouthLandmark.y - headCenterLandmark.y

      for hairRenderer in @hairRenderers when hairRenderer.options.part.options.type is LOI.Character.Part.Types.Avatar.Body.FacialHair.options.type
        for hairShapeRenderer in hairRenderer.renderers()
          hairShapeRenderer._regionOriginOffset ?= {}
          hairShapeRenderer._regionOriginOffset[side] = regionOriginOffset

  drawToContext: (context, options = {}) ->
    return unless @ready()

    # Depend on landmarks to update when renderer translations change.
    @landmarks[options.side]()

    # If we're drawing only the head also draw the hair behind and in the middle.
    if options.rootPart is @options.part
      @drawHairRenderersToContext 'HairBehind', context, options
      @drawHairRenderersToContext 'HairMiddle', context, options

    # Draw main head renderers.
    super arguments...

    # Draw hair over head renderers.
    @drawHairRenderersToContext 'HairFront', context, options

  drawHairRenderersToContext: (regionId, context, options) ->
    for hairRenderer in @hairRenderers
      # Apply hair renderer's transform.
      context.save()

      translation = _.defaults {}, hairRenderer._translation[options.side],
        x: 0
        y: 0

      context.translate translation.x, translation.y

      # Draw hair shapes in the desired region.
      for hairShapeRenderer in hairRenderer.renderers() when hairShapeRenderer.options.part.properties.region.options.dataLocation() is regionId
        @drawRendererToContext hairShapeRenderer, context, options

      # Restore context back to head's transform.
      context.restore()
