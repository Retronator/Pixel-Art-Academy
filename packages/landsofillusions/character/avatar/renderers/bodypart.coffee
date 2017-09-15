LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.BodyPart extends LOI.Character.Avatar.Renderers.Renderer
  constructor: ->
    super

    # Prepare renderer only when it has been created with engine options passed in.
    return unless @engineOptions

    @renderers = []
    @_createRenderers()

    @landmarks = new ComputedField =>
      # Create landmarks and update renderer translations.
      @_landmarks = {}

      # We start with the origin landmark.
      @_landmarks[@options.origin.landmark] =
        x: @options.origin.x or 0
        y: @options.origin.y or 0
        
      @_placeRenderers()

      @_landmarks

  _createRenderer: (propertyName, options) ->
    property = @options.part.properties[propertyName]

    # Add pass-through renderer options.
    propertyRendererOptions = _.extend
      flippedHorizontal: @options.flippedHorizontal
      landmarksSource: @options.landmarksSource
      materialsData: @options.materialsData
    ,
      options

    if property.part
      renderer = property.part.createRenderer @engineOptions, propertyRendererOptions
      @renderers.push renderer

      renderer

    else if property.parts
      for part in property.parts()
        renderer = part.createRenderer @engineOptions, propertyRendererOptions
        @renderers.push renderer

        renderer

  _addLandmarks: (renderer, options = {}) ->
    offsetX = options.offsetX or 0
    offsetY = options.offsetY or 0

    # Add all landmarks from this renderer.
    for rendererLandmarkName, rendererLandmark of renderer.landmarks()
      translatedLandmark = _.extend {}, rendererLandmark,
        x: rendererLandmark.x + renderer._translation.x + offsetX
        y: rendererLandmark.y + renderer._translation.y + offsetY

      @_landmarks[rendererLandmarkName] = translatedLandmark

  _placeRenderer: (renderer, rendererLandmarkName, landmarkName, options = {}) ->
    rendererLandmarks = renderer.landmarks()
    return unless @_landmarks[landmarkName] and rendererLandmarks?[rendererLandmarkName]

    offsetX = options.offsetX or 0
    offsetY = options.offsetY or 0

    renderer._translation =
      x: @_landmarks[landmarkName].x
      y: @_landmarks[landmarkName].y - rendererLandmarks[rendererLandmarkName].y + offsetY

    if renderer._flipHorizontal
      renderer._translation.x += rendererLandmarks[rendererLandmarkName].x + 1 - offsetX

    else
      renderer._translation.x -= rendererLandmarks[rendererLandmarkName].x - offsetX

    @_addLandmarks renderer, options unless options.skipAddingLandmarks

  _bodyPartType: (partName) ->
    LOI.Character.Part.Types.Avatar.Body[partName].options.type

  drawToContext: (context, options = {}) ->
    # Depend on landmarks to update when renderer translations change.
    @landmarks()

    for renderer in @renderers
      @drawRendererToContext renderer, context, options

  drawRendererToContext: (renderer, context, options = {}) ->
    context.save()

    translation = _.defaults {}, renderer._translation,
      x: 0
      y: 0

    context.translate translation.x, translation.y

    if renderer._flipHorizontal
      context.scale -1, 1

    renderer.drawToContext context
    context.restore()
