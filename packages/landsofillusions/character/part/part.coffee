LOI = LandsOfIllusions

# The general part that makes a certain aspect of a character (avatar, behavior, etc).
class LOI.Character.Part
  # Types get added in the initialize script.
  @Types: {}

  constructor: (@options) ->
    return unless @options.dataNode

    # Instantiate all the properties.
    @properties = for propertyName, property of @options.properties
      property.create @options.dataNode.field propertyName

  create: (dataNode) ->
    # We create a copy of ourselves with the data added.
    new @constructor _.extend {}, @options, {dataNode}
