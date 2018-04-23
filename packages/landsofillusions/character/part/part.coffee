AM = Artificial.Mummification
LOI = LandsOfIllusions

# The general part that makes a certain aspect of a character (avatar, behavior, etc).
class LOI.Character.Part
  # Types will get added in the initialize script.
  @Types = {}

  @registerClasses: (classes) ->
    _.merge @Types, classes

  # Helper to access Types with a nested string.
  @getClassForType: (type) ->
    partClass = _.nestedProperty @Types, type
    return partClass if partClass

    console.error "Can't find part of type", type

  constructor: (@options) ->
    return unless @options.dataLocation

    # Use default renderer if not set.
    @options.renderer ?= new LOI.Character.Avatar.Renderers.Default

    # Instantiate all the properties.
    @properties = {}

    for propertyName, property of @options.properties
      propertyDataLocation = @options.dataLocation.child propertyName
      
      @properties[propertyName] = property.create
        dataLocation: propertyDataLocation
        parent: @

    # Create renderer for drawing this part's hierarchy.
    @renderer = new ComputedField =>
      @createRenderer()
    ,
      true

  destroy: ->
    property.destroy() for property in @properties
    @renderer.stop()

  create: (options) ->
    # Set this part's type as template meta data.
    options.dataLocation.setTemplateMetaData
      type: @options.type

    # We create a copy of ourselves with the instance options added.
    new @constructor _.extend {}, @options, options
    
  ready: ->
    # Part is ready when its data location is ready.
    @options.dataLocation.ready()

  # Creates a new renderer hierarchy with given modifier options.
  createRenderer: (options = {}) ->
    # Override to provide this part's renderer.
    options = _.extend {}, options, part: @

    @options.renderer.create options

  ancestorPartOfType: (typeTemplate) ->
    targetType = typeTemplate.options.type

    parent = @options.parent

    while parent and parent.options.type isnt targetType
      parent = parent.options.parent

    parent
