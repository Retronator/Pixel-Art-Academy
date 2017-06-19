LOI = LandsOfIllusions

class LOI.Character.Part.Renderers.HumanAvatar extends LOI.Character.Part.Renderers.Renderer
  constructor: ->
    super

    # Prepare renderer only when it has been created with engine options passed in.
    return unless @engineOptions

    @renderers = [
      @options.humanAvatar.body.createRenderer @engineOptions
      @options.humanAvatar.outfit.createRenderer @engineOptions
    ]

  drawToContext: (context, options = {}) ->
    for renderer in @renderers
      context.save()
      renderer.drawToContext context
      context.restore()
