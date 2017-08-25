LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Body extends LOI.Character.Avatar.Renderers.Renderer
  constructor: ->
    super

    # Prepare renderer only when it has been created with engine options passed in.
    return unless @engineOptions

    @renderers = []

    bodyPartType = (partName) => LOI.Character.Part.Types.Avatar.Body[partName].options.type

    for propertyName, property of @options.part.properties
      switch property.options.type
        when bodyPartType 'Head'
          @headRenderer = property.part.createRenderer @engineOptions
          @renderers.push @headRenderer

        when bodyPartType 'Torso'
          @torsoRenderer = property.part.createRenderer @engineOptions
          @renderers.push @torsoRenderer

        when bodyPartType 'Legs'
          @leftLegRenderer = property.part.createRenderer @engineOptions
          @rightLegRenderer = property.part.createRenderer @engineOptions, flippedHorizontal: true
          @rightLegRenderer._flipHorizontal = true
          @renderers.push @leftLegRenderer
          @renderers.push @rightLegRenderer

        when bodyPartType 'Arms'
          @leftArmRenderer = property.part.createRenderer @engineOptions
          @rightArmRenderer = property.part.createRenderer @engineOptions, flippedHorizontal: true
          @rightArmRenderer._flipHorizontal = true
          @renderers.push @leftArmRenderer
          @renderers.push @rightArmRenderer

    @landmarks = new ComputedField =>
      # Create landmarks and update renderer translations.
      landmarks = {}

      # We start with the origin landmark.
      landmarks[@options.origin.landmark] =
        x: @options.origin.x or 0
        y: @options.origin.y or 0

      addLandmarks = (renderer) =>
        # Add all landmarks from this renderer.
        for rendererLandmarkName, rendererLandmark of renderer.landmarks()
          translatedLandmark = _.extend {}, rendererLandmark,
            x: rendererLandmark.x + renderer._translation.x
            y: rendererLandmark.y + renderer._translation.y

          landmarks[rendererLandmarkName] = translatedLandmark

      placeRenderer = (renderer, rendererLandmarkName, landmarkName) =>
        rendererLandmarks = renderer.landmarks()
        return unless landmarks[landmarkName] and rendererLandmarks[rendererLandmarkName]

        renderer._translation =
          x: landmarks[landmarkName].x - rendererLandmarks[rendererLandmarkName].x
          y: landmarks[landmarkName].y - rendererLandmarks[rendererLandmarkName].y

        addLandmarks renderer

      # Place the torso.
      placeRenderer @torsoRenderer, 'navel', 'navel'

      # Place the head.
      placeRenderer @headRenderer, 'suprasternalNotch', 'suprasternalNotch'

      # Place the legs.
      placeRenderer @leftLegRenderer, 'acetabulum', 'acetabulumLeft'
      placeRenderer @rightLegRenderer, 'acetabulum', 'acetabulumRight'

      # Place the arms.
      placeRenderer @leftArmRenderer, 'shoulder', 'shoulderLeft'
      placeRenderer @rightArmRenderer, 'shoulder', 'shoulderRight'

      landmarks

  drawToContext: (context, options = {}) ->
    # Depend on landmarks to update when renderer translations change.
    @landmarks()

    for renderer in @renderers
      context.save()

      translation = _.defaults {}, renderer._translation,
        x: 0
        y: 0

      context.translate translation.x, translation.y

      if renderer._flipHorizontal
        context.scale -1, 1
        context.translate -1, 0

      renderer.drawToContext context
      context.restore()
