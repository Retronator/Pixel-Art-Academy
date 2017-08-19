LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, @engineOptions) ->

  landmarks: ->
    # Override to provide landmarks in this renderer's coordinate system.

  create: (options, engineOptions) ->
    # We create a copy of ourselves with the instance options added.
    new @constructor _.extend({}, @options, options), engineOptions
