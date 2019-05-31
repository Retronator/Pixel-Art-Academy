LOI = LandsOfIllusions

# This is a default renderer that simply renders all the parts found in the properties.
class LOI.Character.Avatar.Renderers.Default extends LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    propertyRendererOptions = @_cloneRendererOptions()

    @_renderers = []
    @renderers = new ComputedField =>
      renderer.destroy() for renderer in @_renderers
      @_renderers = []

      for propertyName, property of @options.part.properties
        if property instanceof LOI.Character.Part.Property.OneOf
          renderer = property.part.createRenderer propertyRendererOptions
          renderer.options.propertyName = propertyName
          @_renderers.push renderer if renderer

        else if property instanceof LOI.Character.Part.Property.Array
          for part in property.parts()
            renderer = part.createRenderer propertyRendererOptions
            renderer.options.propertyName = propertyName
            @_renderers.push renderer if renderer

      @_renderers

    for side in @options.renderingSides
      do (side) =>
        @landmarks[side] = new ComputedField =>
          # Create landmarks and update renderer translations.
          landmarks = []
    
          # If we have a landmarks source, we use it.
          if landmarksSource = @options.landmarksSource?()
            landmarks.push landmarksSource.landmarks[side]()...
    
            initialLandmark = true if landmarks.length
    
          else
            # We start with the origin landmark.
            if origin = @getOrigin()
              landmarks.push
                name: origin.landmark
                x: origin.x or 0
                y: origin.y or 0
    
              initialLandmark = true
    
          # Calculate translations of all renderers by matching the
          # landmarks until all renderers' translations have been determined.
          undeterminedRenderers = _.clone @renderers()
          processedWithoutMatch = 0
    
          # Clear existing translations.
          renderer._translation[side] = null for renderer in undeterminedRenderers
    
          while processedWithoutMatch < undeterminedRenderers.length
            renderer = undeterminedRenderers.shift()
    
            # Find if any of the renderer's landmarks matches any of ours.
            rendererLandmarks = renderer.landmarks[side]() or []
    
            for rendererLandmark in rendererLandmarks
              landmark = _.find landmarks, (landmark) => landmark.name is rendererLandmark.name
                
              if landmark or not initialLandmark
                if landmark
                  renderer._translation[side] =
                    x: landmark.x - rendererLandmark.x
                    y: landmark.y - rendererLandmark.y
    
                  renderer._depth[side] = landmark.z or 0
    
                else
                  renderer._translation[side] = x: 0, y: 0
                  renderer._depth[side] = 0
    
                # Add all other landmarks from this renderer.
                regionId = @getRegionId()
    
                for rendererLandmark in rendererLandmarks
                  translatedLandmark = _.clone rendererLandmark
    
                  # When rendering a texture, only translate landmarks inside the same region.
                  if not @options.renderTexture or rendererLandmark.regionId is regionId
                    translatedLandmark.x += renderer._translation[side].x
                    translatedLandmark.y += renderer._translation[side].y
    
                  landmarks.push translatedLandmark
                  initialLandmark = true
    
                processedWithoutMatch = 0
                break
    
            unless renderer._translation[side]
              processedWithoutMatch++
              undeterminedRenderers.push renderer
    
          @_applyLandmarksRegion landmarks
    
          landmarks
        ,
          true
  
        @usedLandmarks[side] = new ComputedField =>
          landmarks = _.uniq _.flatten (renderer.usedLandmarks[side]?() for renderer in @renderers())
          _.without landmarks, undefined
        ,
          true
          
        @usedLandmarksCenter[side] = new ComputedField =>
          @_usedLandmarksCenter side
        ,
          true

    @_ready = new ComputedField =>
      _.every @renderers(), (renderer) => renderer.ready()
    ,
      true

  destroy: ->
    renderer.destroy() for renderer in @renderers()
    @renderers.stop()
    
    for side in @options.renderingSides
      @landmarks[side].stop()
      @usedLandmarks[side].stop()
      @usedLandmarksCenter[side].stop()
      
    @_ready.stop()

  ready: ->
    @_ready()

  getRendererForPartType: (type) ->
    _.find @renderers(), (renderer) -> renderer.options.part.options.type is type

  drawToContext: (context, options = {}) ->
    super arguments...
    
    return unless @ready()

    # Depend on landmarks to update when renderer translations change.
    @landmarks[options.side]()

    context.save()
    @_handleRegionTransform context, options

    # Sort renderers by depth.
    sortedRenderers = @_getSortedRenderers options

    for renderer in sortedRenderers
      context.save()

      if @options.centerOnUsedLandmarks
        center = @usedLandmarksCenter[options.side]()

        translation =
          x: -center.x
          y: -center.y

      else
        translation = _.defaults {}, renderer._translation[options.side],
          x: 0
          y: 0
  
      context.translate translation.x, translation.y

      renderer.drawToContext context, options
      context.restore()

    context.restore()

  _getSortedRenderers: (options) ->
    # Override to provide a custom sorting of renderers.
    _.sortBy @renderers(), (renderer) => renderer._depth[options.side]
