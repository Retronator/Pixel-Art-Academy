LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, initialize) ->

  ready: ->
    # Override to delay rendering while not ready.
    true

  landmarks: ->
    # Override to provide landmarks in this renderer's coordinate system.

  create: (options) ->
    # We create a copy of ourselves with the instance options added.
    new @constructor _.extend({}, @options, options), true

  drawToContext: (context, options = {}) ->
    # Override to draw this part into the canvas context.
    
  _cloneRendererOptions: ->
    flippedHorizontal: @options.flippedHorizontal
    landmarksSource: @options.landmarksSource
    materialsData: @options.materialsData
    renderTexture: @options.renderTexture
    viewingAngle: @options.viewingAngle
    regionSide: @options.regionSide
    
  _applyLandmarksRegion: (landmarks) ->
    return unless landmarks

    # Apply region ID to all landmarks.
    return unless regionId = @_getRegionId()

    for landmark in landmarks
      landmark.regionId = regionId

  _getRegionId: ->
    return unless @options.region

    if @options.region.options.multipleRegions
      # Choose the region that matches the renderer's region side.
      for multipleRegionId in @options.region.options.multipleRegions
        if multipleRegionId.indexOf(@options.regionSide) >= 0
          return multipleRegionId

    else
      @options.region.id

  _shouldDraw: (options) ->
    return true unless regionId = @_getRegionId()
    return true unless drawRegion = options.region

    # We only draw when our region matches the one being drawn.
    drawRegion.matchRegion regionId
