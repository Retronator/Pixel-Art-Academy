AM = Artificial.Mummification
LOI = LandsOfIllusions

# The general part that makes a certain aspect of a character (avatar, behavior, etc).
class LOI.Character.Part
  # Types get added in the initialize script.
  @Types: {}
  
  constructor: (@options) ->
    return unless @options.dataLocation

    # Instantiate all the properties.
    @properties = for propertyName, property of @options.properties
      propertyDataLocation = @options.dataLocation.child propertyName
      property.create dataLocation: propertyDataLocation

  create: (options) ->
    # We create a copy of ourselves with the instance options added.
    new @constructor _.extend {}, @options, options
