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
      @_landmarks = {}

      # We start with the origin landmark.
      @_landmarks[@options.origin.landmark] =
        x: @options.origin.x or 0
        y: @options.origin.y or 0
        z: 0
        
      @_placeRenderers()

      @_landmarks

    @_ready = new ComputedField =>
      _.every @renderers, (renderer) => renderer.ready()

  ready: ->
    @_ready()

  _createRenderer: (propertyName, options) ->
    property = @options.part.properties[propertyName]

    # Add pass-through renderer options.
    propertyRendererOptions = _.extend
      flippedHorizontal: @options.flippedHorizontal
      landmarksSource: @options.landmarksSource
      materialsData: @options.materialsData
      renderTexture: @options.renderTexture
      viewingAngle: @options.viewingAngle
    ,
      options

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

    # Add all landmarks from this renderer.
    for rendererLandmarkName, rendererLandmark of renderer.landmarks()
      translatedLandmark = _.extend {}, rendererLandmark,
        x: renderer._translation.x + offsetX
        y: rendererLandmark.y + renderer._translation.y + offsetY

      if renderer._flipHorizontal
        translatedLandmark.x -= rendererLandmark.x + 1

      else
        translatedLandmark.x += rendererLandmark.x

      @_landmarks[rendererLandmarkName] = translatedLandmark

  _placeRenderer: (renderer, rendererLandmarkName, landmarkName, options = {}) ->
    rendererLandmarks = renderer.landmarks()

    if @options.renderTexture and @options.textureOrigins?[landmarkName]
      # Use the provided origin as the landmark target.
      landmark = @options.textureOrigins[landmarkName]

    else
      # Map to the already placed landmark.
      landmark = @_landmarks[landmarkName]

    return unless landmark and rendererLandmarks?[rendererLandmarkName]

    offsetX = options.offsetX or 0
    offsetY = options.offsetY or 0

    renderer._translation =
      x: landmark.x
      y: landmark.y - rendererLandmarks[rendererLandmarkName].y + offsetY

    if renderer._flipHorizontal
      renderer._translation.x += rendererLandmarks[rendererLandmarkName].x + 1 - offsetX

    else
      renderer._translation.x -= rendererLandmarks[rendererLandmarkName].x - offsetX

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
    if options.region and @options.part.options.region
      # Skip if we're not part of the region that's being drawn.
      return unless options.region.match @options.part.options.region
    
    return unless @ready()

    context.save()

    translation = _.defaults {}, renderer._translation,
      x: 0
      y: 0

    context.translate translation.x, translation.y

    if renderer._flipHorizontal
      context.scale -1, 1

    renderer.drawToContext context, options
    context.restore()
