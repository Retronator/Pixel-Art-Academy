LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.BodyPart extends LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    @renderers = []
    @_createRenderers()

    @landmarks = new ComputedField =>
      # Create landmarks and update renderer translations.
      @_landmarks = []

      # We start with the origin landmark.
      origin = @getOrigin()

      @_landmarks.push
        name: origin.landmark
        x: origin.x or 0
        y: origin.y or 0
        z: 0
        
      @_placeRenderers()

      @_applyLandmarksRegion @_landmarks

      @_landmarks

    @_ready = new ComputedField =>
      _.every @renderers, (renderer) => renderer.ready()

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

  _addLandmarks: (renderer, options = {}) ->
    offsetX = options.offsetX or 0
    offsetY = options.offsetY or 0

    regionId = @getRegionId()

    # Add all landmarks from this renderer.
    for rendererLandmark in renderer.landmarks()
      translatedLandmark = _.clone rendererLandmark

      if not @options.renderTexture or rendererLandmark.regionId is regionId
        translatedLandmark.x = renderer._translation.x + offsetX
        translatedLandmark.y += renderer._translation.y + offsetY

        if renderer._flipHorizontal
          translatedLandmark.x -= rendererLandmark.x + 1

        else
          translatedLandmark.x += rendererLandmark.x

      @_landmarks.push translatedLandmark

  _placeRenderer: (renderer, rendererLandmarkName, landmarkName, options = {}) ->
    rendererLandmarks = renderer.landmarks()
    rendererLandmark = _.find rendererLandmarks, (landmark) => landmark.name is rendererLandmarkName

    landmark = _.find @_landmarks, (landmark) => landmark.name is landmarkName

    return unless landmark and rendererLandmark

    offsetX = options.offsetX or 0
    offsetY = options.offsetY or 0

    renderer._translation =
      x: landmark.x
      y: landmark.y - rendererLandmark.y + offsetY

    if renderer._flipHorizontal
      renderer._translation.x += rendererLandmark.x + 1 - offsetX

    else
      renderer._translation.x -= rendererLandmark.x - offsetX

    renderer._depth = landmark.z or 0

    @_addLandmarks renderer, options unless options.skipAddingLandmarks

  _bodyPartType: (partName) ->
    LOI.Character.Part.Types.Avatar.Body[partName].options.type

  drawToContext: (context, options = {}) ->
    # Depend on landmarks to update when renderer translations change.
    @landmarks()

    # Sort renderers by depth.
    sortedRenderers = _.sortBy @renderers, (renderer) => renderer._depth

    for renderer in sortedRenderers
      @drawRendererToContext renderer, context, options

  drawRendererToContext: (renderer, context, options = {}) ->
    return unless @ready()

    context.save()
    @_handleRegionTransform context, options

    translation = _.defaults {}, renderer._translation,
      x: 0
      y: 0

    context.translate translation.x, translation.y

    if renderer._flipHorizontal
      context.scale -1, 1

    renderer.drawToContext context, options
    context.restore()
