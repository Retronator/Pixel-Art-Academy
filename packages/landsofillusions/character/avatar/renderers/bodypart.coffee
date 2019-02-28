LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.BodyPart extends LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    @renderers = []
    @_createRenderers()

    @_landmarks = {}

    for side in @options.renderingSides
      do (side) =>
        @landmarks[side] = new ComputedField =>
          # Create landmarks and update renderer translations.
          @_landmarks[side] = []

          # We start with the origin landmark.
          origin = @getOrigin()

          @_landmarks[side].push
            name: origin.landmark
            x: origin.x or 0
            y: origin.y or 0
            z: 0

          @_placeRenderers side
          @_applyLandmarksRegion @_landmarks[side]

          @_landmarks[side]
        ,
          true

    @_ready = new ComputedField =>
      _.every @renderers, (renderer) => renderer.ready()
    ,
      true
    
  destroy: ->
    renderer.destroy() for renderer in @renderers

    for side in @options.renderingSides
      @landmarks[side].stop()

    @_ready.stop()

  ready: ->
    @_ready()

  _createRenderer: (propertyName, options) ->
    property = @options.part.properties[propertyName]

    # Add pass-through renderer options.
    propertyRendererOptions = _.extend @_cloneRendererOptions(), options

    if property.part
      renderer = property.part.createRenderer propertyRendererOptions
      @renderers.push renderer

      renderer

    else if property.parts
      for part in property.parts()
        renderer = part.createRenderer propertyRendererOptions
        @renderers.push renderer

        renderer

  _addLandmarks: (side, renderer, options = {}) ->
    offsetX = options.offsetX or 0
    offsetY = options.offsetY or 0

    regionId = @getRegionId()

    # Add all landmarks from this renderer.
    for rendererLandmark in renderer.landmarks[side]()
      translatedLandmark = _.clone rendererLandmark

      if not @options.renderTexture or rendererLandmark.regionId is regionId
        translatedLandmark.x = renderer._translation[side].x + offsetX
        translatedLandmark.y += renderer._translation[side].y + offsetY

        if renderer._flipHorizontal
          translatedLandmark.x -= rendererLandmark.x + 1

        else
          translatedLandmark.x += rendererLandmark.x

      # When returning symmetric landmarks in the same region, append the suffix to their end.
      if renderer.options.regionSide and rendererLandmark.regionId is regionId
        translatedLandmark.name += renderer.options.regionSide

      @_landmarks[side].push translatedLandmark

  _placeRenderer: (side, renderer, rendererLandmarkName, landmarkName, options = {}) ->
    rendererLandmarks = renderer.landmarks[side]()
    rendererLandmark = _.find rendererLandmarks, (landmark) => landmark.name is rendererLandmarkName

    landmark = _.find @_landmarks[side], (landmark) => landmark.name is landmarkName

    return unless landmark and rendererLandmark

    offsetX = options.offsetX or 0
    offsetY = options.offsetY or 0

    renderer._translation[side] =
      x: landmark.x
      y: landmark.y - rendererLandmark.y + offsetY

    if renderer._flipHorizontal
      renderer._translation[side].x += rendererLandmark.x + 1 - offsetX

    else
      renderer._translation[side].x -= rendererLandmark.x - offsetX

    renderer._depth[side] = landmark.z or 0

    @_addLandmarks side, renderer, options unless options.skipAddingLandmarks

  _bodyPartType: (partName) ->
    LOI.Character.Part.Types.Avatar.Body[partName].options.type

  drawToContext: (context, options = {}) ->
    
    # Depend on landmarks to update when renderer translations change.
    @landmarks[options.side]()

    # Sort renderers by depth.
    sortedRenderers = _.sortBy @renderers, (renderer) => renderer._depth[options.side]

    for renderer in sortedRenderers
      @drawRendererToContext renderer, context, options

  drawRendererToContext: (renderer, context, options = {}) ->
    return unless @ready()

    context.save()
    @_handleRegionTransform context, options

    translation = _.defaults {}, renderer._translation[options.side],
      x: 0
      y: 0

    context.translate translation.x, translation.y

    if renderer._flipHorizontal
      context.scale -1, 1

    renderer.drawToContext context, options
    context.restore()
