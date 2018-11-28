AM = Artificial.Mummification
LOI = LandsOfIllusions

# The general part that makes a certain aspect of a character (avatar, behavior, etc).
class LOI.Character.Part
  # Types will get added in the initialize script.
  @Types = {}

  @registerClasses: (classes) ->
    _.merge @Types, classes
          
  @allPartTypeIds: ->
    _.flatten [
      @getPartTypeIdsUnderType 'Avatar.Body'
      'Avatar.Outfit'
      @getPartTypeIdsUnderType 'Avatar.Outfit'
      @getPartTypeIdsUnderType 'Behavior'
    ]
    
  @getPartTypeIdsUnderType = (type) =>
    types = []

    # Go over all the properties of the type and add all sub-types.
    typeClass = _.nestedProperty LOI.Character.Part.Types, type

    for propertyName, property of typeClass.options.properties when property.options?.type?
      templateType = property.options.templateType or property.options.type
      type = property.options.type

      types.push templateType
      types.push @getPartTypeIdsUnderType(type)...
      
    types

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

  destroy: ->
    property.destroy() for property in @properties

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

  childPartOfType: (typeTemplateOrId) ->
    targetType = typeTemplateOrId.options?.type or typeTemplateOrId
    return @ if @options.type is targetType

    for propertyName, property of @properties
      child = property.childPartOfType typeTemplateOrId
      return child if child
      
    null
