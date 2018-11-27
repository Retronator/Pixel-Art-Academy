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
    options = _.extend {}, @options, options
    
    # Region is a property that gets priority coming from constructor options.
    options.region = @options.region if @options?.region
    
    new @constructor options, true

  drawToContext: (context, options = {}) ->
    # Override to draw this part into the canvas context.
    
  _cloneRendererOptions: ->
    flippedHorizontal: @options.flippedHorizontal
    landmarksSource: @options.landmarksSource
    materialsData: @options.materialsData
    renderTexture: @options.renderTexture
    viewingAngle: @options.viewingAngle
    regionSide: @options.regionSide
    region: @options.region
    bodyPart: @options.bodyPart
    
  _applyLandmarksRegion: (landmarks) ->
    return unless landmarks

    # Apply region ID to all landmarks that haven't had a region assigned yet.
    return unless regionId = @_getRegionId()

    for landmark in landmarks
      landmark.regionId ?= regionId

  _getRegionId: ->
    if propertyRegionId = @options.part.properties.region?.options.dataLocation()
      region = LOI.HumanAvatar.Regions[propertyRegionId]

    else
      region = @options.region

    return unless region

    if region.options.multipleRegions
      # Choose the region that matches the renderer's region side.
      for multipleRegionId in region.options.multipleRegions
        if multipleRegionId.indexOf(@options.regionSide) >= 0
          return multipleRegionId

    else
      region.id

  _shouldDraw: (options) ->
    return true unless regionId = @_getRegionId()
    return true unless drawRegion = options.region

    # We only draw when our region matches the one being drawn.
    drawRegion.matchRegion regionId

  _renderingConditionsSatisfied: ->
    # We can evaluate conditions only when we have a bodyPart source set.
    return true unless bodyPart = @options.bodyPart()

    # See if there is a rendering condition set on the part.
    combinationType = @options.part.properties.condition.combinationType()
    conditionParts = @options.part.properties.condition.conditionParts()

    conditionResults = for partType, regex of conditionParts
      # Find the part set on the type location.
      part = bodyPart.childPartOfType partType
      partNode = part.options.dataLocation()

      # See if the part is a template and its name matches our test regex.
      templateName = partNode?.template?.name.translations.best.text
      new RegExp(regex).test templateName

    return true unless conditionResults.length

    if combinationType is LOI.Character.Avatar.Properties.RenderingCondition.CombinationTypes.All
      _.every conditionResults

    else
      _.some conditionResults
