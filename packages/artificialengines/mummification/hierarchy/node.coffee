AM = Artificial.Mummification

class AM.Hierarchy.Node
  # For data passed to the node, refer to template document structure.
  constructor: (options) ->
    hierarchyFields = {}

    fieldGetter = (fieldName) ->
      # We want to create a new internal hierarchy field that we'll depend upon to isolate reactivity.
      unless hierarchyFields[fieldName]
        hierarchyFields[fieldName] = new AM.Hierarchy.Field _.extend {}, options,
          address: options.address.fieldChild fieldName
          load: =>
            options.load()?.fields[fieldName]
          save: options.save

      hierarchyFields[fieldName]

    # We want the hierarchy node to behave as getter/setter to which we pass a field name and new value.
    node = (fieldName, value) ->
      field = fieldGetter fieldName

      # Delegate to hierarchy field.
      field value

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf node, @constructor.prototype

    # Store options on node.
    node.options = options

    # Transfer the presence of a template.
    node.template = options?.template
    
    node.field = (fieldName) ->
      fieldGetter fieldName
      
    # Returns the raw loaded data directly.
    node.data = ->
      options.load()

    node.destroy = ->
      field.destroy() for name, field of hierarchyFields

    # Return the node getter/setter function (return must be explicit).
    return node
