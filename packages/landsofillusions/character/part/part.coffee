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
      property.create
        dataLocation: propertyDataLocation
        parentPart: @

  destroy: ->
    property.destroy() for property in @properties

  create: (options) ->
    # Set this part's type as template meta data.
    options.dataLocation.setTemplateMetaData
      type: @options.type

    # We create a copy of ourselves with the instance options added.
    new @constructor _.extend {}, @options, options

  createRenderer: (engineOptions, options = {}) ->
    # Override to provide this part's renderer.
    renderer = @options.renderer or new LOI.Character.Part.Renderers.Default

    options = _.extend {}, options, part: @
    
    renderer.create options, engineOptions
