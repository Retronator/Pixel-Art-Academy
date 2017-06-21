LOI = LandsOfIllusions

# This is a default renderer that simply renders all the parts found in the properties.
class LOI.Character.Part.Renderers.Default extends LOI.Character.Part.Renderers.Renderer
  constructor: ->
    super

    # Prepare renderer only when it has been created with engine options passed in.
    return unless @engineOptions

    propertyRendererOptions =
      flippedHorizontal: @options.flippedHorizontal
      landmarksSource: @options.landmarksSource

    @renderers = new ComputedField =>
      renderers = []

      for property in @options.part.properties
        if property instanceof LOI.Character.Part.Property.OneOf
          renderer = property.part.createRenderer @engineOptions, propertyRendererOptions
          renderers.push renderer if renderer

        else if property instanceof LOI.Character.Part.Property.Array
          for part in property.parts()
            renderer = part.createRenderer @engineOptions, propertyRendererOptions
            renderers.push renderer if renderer

      renderers

    @landmarks = new ComputedField =>
      # Create landmarks and update renderer translations.
      landmarks = {}

      # We start with the origin landmark.
      if @options.origin
        landmarks[@options.origin.landmark] =
          x: @options.origin.x or 0
          y: @options.origin.y or 0

        initialLandmark = true

      # Calculate translations of all renderers by matching the
      # landmarks until all renderers' translations have been determined.
      undeterminedRenderers = _.clone @renderers()
      processedWithoutMatch = 0

      # Clear existing translations.
      renderer._translation = null for renderer in undeterminedRenderers

      while processedWithoutMatch < undeterminedRenderers.length
        renderer = undeterminedRenderers.shift()

        # Find if any of the renderer's landmarks matches any of ours.
        rendererLandmarks = renderer.landmarks()
        for rendererLandmarkName, rendererLandmark of rendererLandmarks
          landmark = landmarks[rendererLandmarkName]
          if landmark or not initialLandmark
            if landmark
              renderer._translation =
                x: landmark.x - rendererLandmark.x
                y: landmark.y - rendererLandmark.y

            else
              renderer._translation = x: 0, y: 0

            # Add all other landmarks from this renderer.
            for rendererLandmarkName, rendererLandmark of rendererLandmarks
              translatedLandmark = _.extend {}, rendererLandmark,
                x: rendererLandmark.x + renderer._translation.x
                y: rendererLandmark.y + renderer._translation.y

              landmarks[rendererLandmarkName] = translatedLandmark
              initialLandmark = true

            processedWithoutMatch = 0
            break

        unless renderer._translation
          processedWithoutMatch++
          undeterminedRenderers.push renderer

      landmarks

  getRendererForPartType: (type) ->
    _.find @renderers(), (renderer) -> renderer.options.part.options.type is type

  drawToContext: (context, options = {}) ->
    # Depend on landmarks to update when renderer translations change.
    @landmarks()

    for renderer in @renderers()
      context.save()

      translation = _.defaults {}, renderer._translation,
        x: 0
        y: 0

      context.translate translation.x, translation.y

      renderer.drawToContext context, options
      context.restore()
