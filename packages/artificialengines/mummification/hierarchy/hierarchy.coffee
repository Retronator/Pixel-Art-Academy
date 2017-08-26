AM = Artificial.Mummification

class AM.Hierarchy
  @create: (options) ->
    # Create a blank address if needed.
    options.address ?= new AM.Hierarchy.Address

    # Build a hierarchy of nodes that represents the data.
    new @Field options

  @convertObjectToStoredValue: (value) ->
    return unless value?

    if value instanceof AM.Hierarchy.Template
      # We're converting a template and just store its ID.
      templateId: storedProperty._id

    else if value instanceof AM.Hierarchy.Node
      # Just copy node's data.
      node: value.data()

    else if _.isObject value
      # We've converting a standard object, which should become a node. Covert its properties as well first.
      node = fields: {}

      for propertyName, property of value
        storedValue = @convertObjectToStoredValue property
        node.fields[propertyName] = storedValue if storedValue?

      {node}

    else
      # We're converting a raw value.
      {value}
