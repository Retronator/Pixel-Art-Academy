AM = Artificial.Mummification
LOI = LandsOfIllusions

# This is a default renderer that simply renders all the parts found in the properties.
class LOI.Character.Avatar.Renderers.OutfitArticlePart extends LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    propertyRendererOptions = @_cloneRendererOptions()

    @_renderers = []
    @renderers = new ComputedField =>
      renderer.destroy() for renderer in @_renderers
      @_renderers = []

      # Get the region we're in.
      return @_renderers unless regionId = @options.part.properties.region.options.dataLocation()
      region = LOI.HumanAvatar.Regions[regionId]

      # Resolve multiple regions.
      regionIds = region.getRegionIds()

      shapeParts = @options.part.properties.shapes.parts()

      for regionId in regionIds
        for part in shapeParts
          renderer = part.createRenderer _.extend propertyRendererOptions,
            region: LOI.HumanAvatar.Regions[regionId]

          @_renderers.push renderer

      @_renderers
    ,
      true

    for side in @options.renderingSides
      do (side) =>
        @landmarks[side] = new ComputedField =>
          # Add article landmarks to source ones.
          sourceLandmarks = @options.landmarksSource?()?.landmarks[side]()
          rendererLandmarks = (renderer.landmarks[side]() for renderer in @renderers())
    
          landmarks = _.flattenDeep [sourceLandmarks, rendererLandmarks]
          _.without landmarks, undefined
        ,
          true
          
        @usedLandmarks[side] = new ComputedField =>
          landmarks = _.uniq _.flatten (renderer.usedLandmarks[side]() for renderer in @renderers())
          _.without landmarks, undefined
        ,
          true
    
        @usedLandmarksCenter[side] = new ComputedField =>
          @_usedLandmarksCenter side
        ,
          true

    @_ready = new ComputedField =>
      _.every @renderers(), (renderer) => renderer.ready()
      
  destroy: ->
    super arguments...

    @renderers.stop()
    renderer.destroy() for renderer in @_renderers

    for side in @options.renderingSides
      @landmarks[side].stop()
      @usedLandmarks[side].stop()
      @usedLandmarksCenter[side].stop()

    @_ready.stop()

  ready: ->
    @_ready()

  drawToContext: (context, options = {}) ->
    super arguments...
    
    return unless @ready() and @_renderingConditionsSatisfied()

    if @options.centerOnUsedLandmarks
      center = @usedLandmarksCenter[options.side]()
      context.translate -Math.round(center.x), -Math.round(center.y)
    
    for renderer in @renderers()
      renderer.drawToContext context, options
