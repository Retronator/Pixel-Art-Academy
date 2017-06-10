LOI = LandsOfIllusions

# A value of a certain aspect of a part.
class LOI.Character.Part.Property
  constructor: (@options = {}) ->
    return unless @options.dataLocation

  destroy: ->

  create: (options) ->
    # We create a copy of ourselves with the data added.
    new @constructor _.extend {}, @options, options
