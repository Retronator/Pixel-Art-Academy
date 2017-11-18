LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.HumanAvatar extends LOI.Character.Avatar.Renderers.Renderer
  constructor: ->
    super

    # Prepare renderer only when it has been created with engine options passed in.
    return unless @engineOptions
    
    bodyRenderer = @options.humanAvatar.body.createRenderer @engineOptions

    outfitRenderer = @options.humanAvatar.outfit.createRenderer @engineOptions,
      landmarksSource: bodyRenderer

    @renderers = [bodyRenderer, outfitRenderer]

  drawToContext: (context, options = {}) ->
    # Make sure all the data is loaded.
    return unless @options.humanAvatar.body.ready() and @options.humanAvatar.outfit.ready()

    # Make sure all the sprites have been rendered and positioned.
    return unless _.every @renderers, (renderer) => renderer.ready()

    for renderer in @renderers
      context.save()
      renderer.drawToContext context
      context.restore()
