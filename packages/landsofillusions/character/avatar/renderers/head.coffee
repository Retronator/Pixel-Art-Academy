LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Head extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    # We create hair renderer separately so we can draw front and back hair in correct order.
    rendererOptions = @_cloneRendererOptions()
    @hairRenderers = for part in @options.part.properties.hair.parts()
      part.createRenderer rendererOptions

    # Create the rest of the renderers normally.
    @headShapeRenderer = @_createRenderer 'shape'
    @leftEyeRenderer = @_createRenderer 'eyes'
    @rightEyeRenderer = @_createRenderer 'eyes', flippedHorizontal: true
    @rightEyeRenderer._flipHorizontal = true
    @facialHairRenderers = @_createRenderer 'facialHair'

  _placeRenderers: ->
    # Place the head shape.
    @_placeRenderer @headShapeRenderer, 'atlas', 'atlas'

    # Place the eyes.
    @_placeRenderer @leftEyeRenderer, 'eyeCenter', 'eyeLeft'
    @_placeRenderer @rightEyeRenderer, 'eyeCenter', 'eyeRight'

    # Place the hair.
    @_placeRenderer hairRenderer, 'headCenter', 'headCenter' for hairRenderer in @hairRenderers

    # Place the facial hair.
    @_placeRenderer facialHairRenderer, 'mouth', 'mouth' for facialHairRenderer in @facialHairRenderers

  getHairRenderers: (regionId) ->
    hairRenderers = for hairRenderer in @hairRenderers
      # Get all hair shape renderers and copy the parent's translation to them.
      renderers = hairRenderer.renderers()
      renderer._translation = hairRenderer._translation for renderer in renderers
      renderers

    _.filter _.flatten(hairRenderers), (hairRenderer) =>
      hairRenderer.options.part.properties.region.options.dataLocation() is regionId

  drawToContext: (context, options = {}) ->
    return unless @ready()

    # Depend on landmarks to update when renderer translations change.
    @landmarks()

    # If we're drawing only the head also draw the hair behind and in the middle.
    if options.rootPart is @options.part
      for renderer in @getHairRenderers 'HairBehind'
        @drawRendererToContext renderer, context, options

      for renderer in @getHairRenderers 'HairMiddle'
        @drawRendererToContext renderer, context, options

    # Draw main head renderers.
    super arguments...

    # Draw hair over head renderers.
    for renderer in @getHairRenderers 'HairFront'
      @drawRendererToContext renderer, context, options
