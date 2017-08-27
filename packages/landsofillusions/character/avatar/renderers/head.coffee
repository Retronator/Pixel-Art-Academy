LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Head extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    # We create hair-behind renderers separately, so they won't render together with the rest of the head.
    @hairBehindRenderers = for part in @options.part.properties.hairBehind.parts()
      part.createRenderer @engineOptions

    # Create the rest of the renderers normally.
    @neckRenderer = @_createRenderer 'neck'
    @headShapeRenderer = @_createRenderer 'shape'
    @leftEyeRenderer = @_createRenderer 'eyes'
    @rightEyeRenderer = @_createRenderer 'eyes', flippedHorizontal: true
    @rightEyeRenderer._flipHorizontal = true
    @hairRenderers = @_createRenderer 'hair'

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
