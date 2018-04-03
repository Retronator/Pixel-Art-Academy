LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.HumanAvatar extends LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, initialize) ->
    super

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    bodyRenderer = @options.humanAvatar.body.createRenderer()

    outfitRenderer = @options.humanAvatar.outfit.createRenderer
      landmarksSource: bodyRenderer

    @renderers = [bodyRenderer, outfitRenderer]

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

    for renderer in @renderers
      context.save()
      renderer.drawToContext context, options
      context.restore()
