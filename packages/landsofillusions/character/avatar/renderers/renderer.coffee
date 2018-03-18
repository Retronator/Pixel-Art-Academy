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
