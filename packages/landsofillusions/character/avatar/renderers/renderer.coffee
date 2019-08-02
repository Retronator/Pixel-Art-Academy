LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options = {}, initialize) ->
    return unless initialize

    # By default we prepare for drawing all rendering sides.
    @options.renderingSides ?= _.values LOI.Engine.RenderingSides.Keys

    # For each rendering side provide landmarks in this renderer's coordinate system.
    @landmarks = {}

    # For each rendering side provide a list of landmark names that the mapped shapes have used to render themselves.
    @usedLandmarks = {}

    # For each rendering side provide average position of all used landmarks.
    @usedLandmarksCenter = {}

    # For each rendering side, store local translations and sorting depth of the renderer.
    @_translation = {}
    @_depth = {}

  destroy: ->
    # Override to clean up.

  ready: ->
    # Override to delay rendering while not ready.
    true

  create: (options) ->
    # We create a copy of ourselves with the instance options added.
    options = _.extend {}, @options, options
    
    # Region is a property that gets priority coming from constructor options.
    # Otherwise the undefined value in options parameters will overwrite it.
    if @options?.region
      options.region = @options.region

    # Same applies to additional landmark regions.
    if @options?.additionalLandmarkRegions
      options.additionalLandmarkRegions = @options.additionalLandmarkRegions

    new @constructor options, true

  drawToContext: (context, options = {}) ->
    # Override to draw this part into the canvas context.
    
  _cloneRendererOptions: ->
    flippedHorizontal: @options.flippedHorizontal
    landmarksSource: @options.landmarksSource
    materialsData: @options.materialsData
    renderTexture: @options.renderTexture
    regionSide: @options.regionSide
    region: @options.region
    additionalLandmarkRegions: @options.additionalLandmarkRegions
    bodyPart: @options.bodyPart
    renderingSides: @options.renderingSides
    useDatabaseSprites: @options.useDatabaseSprites
    useArticleLandmarks: @options.useArticleLandmarks
    parent: @
    
  _applyLandmarksRegion: (landmarks) ->
    return unless landmarks

    # Apply region ID to all landmarks that haven't had a region assigned yet.
    return unless regionId = @getRegionId()

    for landmark in landmarks
      landmark.regionId ?= regionId

    # Duplicate landmarks that should be available in additional regions.
    if @options.additionalLandmarkRegions
      currentRegionLandmarks = _.filter landmarks, (landmark) => landmark.regionId is regionId

      for region in @options.additionalLandmarkRegions
        for currentRegionLandmark in currentRegionLandmarks
          # See if this landmark already exists in this region.
          continue if _.find landmarks, (landmark) -> landmark.name is currentRegionLandmark.name and landmark.regionId is region.id

          # Clone the landmark to the new region.
          additionalLandmark = _.clone currentRegionLandmark
          additionalLandmark.regionId = region.id

          # When adding symmetric landmarks to other regions, append the suffix to their end.
          additionalLandmark.name += @options.regionSide if @options.regionSide

          landmarks.push additionalLandmark

    # When providing render texture landmarks, we need to offset them by the region offset.
    if @options.renderTexture and @isRegionRoot()
      region = @getRegion()
      bounds = region.options.bounds

      for landmark in landmarks
        if landmark.regionId is regionId
          if region.id.indexOf('Right') >= 0
            # This is a mirrored region.
            landmark.x = bounds.right() - landmark.x

          else
            # This is a normal region.
            landmark.x += bounds.x()

          landmark.y += bounds.y()

  getRegionId: ->
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

  getRegion: ->
    LOI.HumanAvatar.Regions[@getRegionId()]

  isRegionRoot: ->
    @getRegionId() isnt @options.parent?.getRegionId()

  _shouldDraw: (options) ->
    return true unless regionId = @getRegionId()
    return true unless drawRegion = options.region

    # We only draw when our region matches the one being drawn.
    drawRegion.matchRegion regionId

  _renderingConditionsSatisfied: ->
    return true if @options.ignoreRenderingConditions
    
    # We can evaluate conditions only when we have a bodyPart source set.
    return true unless bodyPart = @options.bodyPart()

    # See if there is a rendering condition set on the part.
    combinationType = @options.part.properties.condition.combinationType()
    conditionParts = @options.part.properties.condition.conditionParts()

    conditionResults = for partType, regex of conditionParts
      # Find the part set on the type location.
      part = bodyPart.childPartOfType partType
      partNode = part.options.dataLocation()

      # See if the part is a template and its name matches our test regex. The name is saved on the embedded template.
      templateName = partNode?.template?.name

      # For live templates, we have to manually go into the translations.
      templateName = templateName.translations.best.text if templateName?.translations

      new RegExp(regex).test templateName

    return true unless conditionResults.length

    if combinationType is LOI.Character.Avatar.Properties.RenderingCondition.CombinationTypes.All
      _.every conditionResults

    else
      _.some conditionResults
      
  getOrigin: ->
    # When we're rendering to a texture, region origins override other settings.
    if @options.renderTexture and @isRegionRoot()
      @getRegion().options.origin

    else
      @options.origin

  _handleRegionTransform: (context, options) ->
    # When we're drawing a region to a texture, we need to transform to region coordinates.
    return unless @options.renderTexture and @isRegionRoot()

    # Note: We need to get the specific region for this renderer since region in options might hold multiple regions.
    region = @getRegion()
    bounds = region.options.bounds

    if region.id.indexOf('Right') >= 0
      # This is a mirrored region.
      context.setTransform -1, 0, 0, 1, options.textureOffset + bounds.right() + 1, bounds.top()

    else
      # This is a normal region.
      context.setTransform 1, 0, 0, 1, options.textureOffset + bounds.left(), bounds.top()

  _usedLandmarksCenter: (side) ->
    center = x: 0, y: 0

    return center unless landmarks = @options.landmarksSource?()?.landmarks[side]()
    return center unless usedLandmarks = @usedLandmarks[side]()
  
    foundLandmarksCount = 0
  
    for usedLandmark in usedLandmarks
      continue unless landmark = _.find landmarks, (landmark) => landmark.name is usedLandmark
      center.x += landmark.x
      center.y += landmark.y
      foundLandmarksCount++
  
    if foundLandmarksCount > 0
      center.x /= foundLandmarksCount
      center.y /= foundLandmarksCount
  
    center
