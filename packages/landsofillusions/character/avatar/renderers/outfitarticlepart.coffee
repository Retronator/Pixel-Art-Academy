LOI = LandsOfIllusions

# This is a default renderer that simply renders all the parts found in the properties.
class LOI.Character.Avatar.Renderers.OutfitArticlePart extends LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    propertyRendererOptions = @_cloneRendererOptions()

    @renderers = new ComputedField =>
      # Get the region we're in.
      return [] unless regionId = @options.part.properties.region.options.dataLocation()
      region = LOI.HumanAvatar.Regions[regionId]

      # Resolve multiple regions.
      regionIds = region.getRegionIds()

      shapeParts = @options.part.properties.shape.parts()

      renderers = []

      for regionId in regionIds
        for part in shapeParts
          renderer = part.createRenderer _.extend propertyRendererOptions,
            region: LOI.HumanAvatar.Regions[regionId]

          renderers.push renderer

      renderers

    @landmarks = new ComputedField =>
      # Add article landmarks to source ones.
      sourceLandmarks = @options.landmarksSource?().landmarks()
      rendererLandmarks = (renderer.landmarks() for renderer in @renderers())

      landmarks = _.flattenDeep [sourceLandmarks, rendererLandmarks]
      _.without landmarks, undefined

    @_ready = new ComputedField =>
      _.every @renderers(), (renderer) => renderer.ready()

  ready: ->
    @_ready()

  drawToContext: (context, options = {}) ->
    return unless @ready()

    for renderer in @renderers()
      renderer.drawToContext context, options
