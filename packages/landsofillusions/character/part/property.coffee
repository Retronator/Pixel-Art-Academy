LOI = LandsOfIllusions

# A value of a certain aspect of a part.
class LOI.Character.Part.Property
  constructor: (@options = {}) ->
    return unless @options.dataLocation

  destroy: ->

  create: (options) ->
    # Set this property's type as template meta data.
    options.dataLocation.setTemplateMetaData
      type: @options.type

    # We create a copy of ourselves with the data added.
    new @constructor _.extend {}, @options, options

  childPartOfType: (typeTemplateOrId) ->
    # Override to return a child part that matches the type.
