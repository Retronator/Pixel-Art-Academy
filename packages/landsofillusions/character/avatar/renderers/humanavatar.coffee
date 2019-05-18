LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.HumanAvatar extends LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    rendererOptions =
      renderTexture: @options.renderTexture
      renderingSides: @options.renderingSides
      useDatabaseSprites: @options.useDatabaseSprites

    @bodyRenderer = @options.humanAvatar.body.createRenderer rendererOptions

    @outfitRenderer = @options.humanAvatar.outfit.createRenderer _.extend
      landmarksSource: => @bodyRenderer
      bodyPart: => @options.humanAvatar.body
    ,
      rendererOptions

    @renderers = [@bodyRenderer, @outfitRenderer]
    
    @hiddenRegionIds = new ComputedField =>
      hiddenRegionIds = []

      for article in @options.humanAvatar.outfit.properties.articles.parts()
        for articlePart in article.properties.parts.parts()
          for articlePartShape in articlePart.properties.shapes.parts()
            hiddenRegionIds.push articlePartShape.properties.hideRegions.regionIds()...

      hiddenRegionIds

    ,
      true

    @_ready = new ComputedField =>
      # Make sure all the data is loaded.
      return unless @options.humanAvatar.body.ready() and @options.humanAvatar.outfit.ready()

      # Make sure all the sprites have been rendered and positioned.
      return unless _.every @renderers, (renderer) => renderer.ready()

      true
    ,
      true
    
  destroy: ->
    @hiddenRegionIds.stop()
    @_ready.stop()

  ready: ->
    @_ready()

  drawToContext: (context, options = {}) ->
    super arguments...
    
    return unless @ready()

    regions = @constructor.regionsOrder[options.side]

    # Remove regions that are being hidden by article part shapes, but only if we're drawing the outfit.
    if not options.drawOutfit? or options.drawOutfit
      regions = _.filter regions, (region) => region.id not in @hiddenRegionIds()

    @_drawRegionToContext context, _.extend {region}, options for region in regions
    
  _drawRegionToContext: (context, options = {}) ->
    for renderer in @renderers
      # Skip body or outfit drawing if explicitly told so.
      continue if options.drawBody? and not options.drawBody and renderer is @bodyRenderer
      continue if options.drawOutfit? and not options.drawOutfit and renderer is @outfitRenderer

      context.save()
      renderer.drawToContext context, options
      context.restore()
