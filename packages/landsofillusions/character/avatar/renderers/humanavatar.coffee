LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.HumanAvatar extends LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    @bodyRenderer = @options.humanAvatar.body.createRenderer
      renderTexture: @options.renderTexture
      viewingAngle: @options.viewingAngle

    @outfitRenderer = @options.humanAvatar.outfit.createRenderer
      landmarksSource: => @bodyRenderer
      bodyPart: => @options.humanAvatar.body
      renderTexture: @options.renderTexture
      viewingAngle: @options.viewingAngle

    @renderers = [@bodyRenderer, @outfitRenderer]

    @_ready = new ComputedField =>
      # Make sure all the data is loaded.
      return unless @options.humanAvatar.body.ready() and @options.humanAvatar.outfit.ready()

      # Make sure all the sprites have been rendered and positioned.
      return unless _.every @renderers, (renderer) => renderer.ready()

      true

  ready: ->
    @_ready()

  drawToContext: (context, options = {}) ->
    return unless @ready()
    
    if options.viewingAngle
      side = LOI.Engine.RenderingSides.getSideForAngle options.viewingAngle()
      
    else 
      side = LOI.Engine.RenderingSides.Keys.Front

    regions = @constructor.regionsOrder[side]

    # Remove regions that are being hidden by article part shapes, but only if we're drawing the outfit.
    if not @options.drawOutfit? or @options.drawOutfit
      hiddenRegionIds = []

      for article in @options.humanAvatar.outfit.properties.articles.parts()
        for articlePart in article.properties.parts.parts()
          for articlePartShape in articlePart.properties.shapes.parts()
            hiddenRegionIds.push articlePartShape.properties.hideRegions.regionIds()...

      regions = _.filter regions, (region) -> region.id not in hiddenRegionIds

    @_drawRegionToContext context, _.extend {region}, options for region in regions
    
  _drawRegionToContext: (context, options = {}) ->
    for renderer in @renderers
      # Skip outfit if explicitly told so.
      continue if @options.drawOutfit? and not @options.drawOutfit and renderer is @outfitRenderer

      context.save()
      renderer.drawToContext context, options
      context.restore()
