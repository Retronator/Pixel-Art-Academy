AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Hierarchy.Field
  # For data passed to the field, refer to template document structure.
  constructor: (options) ->
    node = null
    templateNode = null
    placeholderNode = null
    metaData = null

    cleanTemplate = ->
      templateNode?.options.load.stop()
      templateNode?.destroy()
      templateNode = null

    cleanNode = ->
      node?.options.load.stop()
      node?.destroy()
      node = null

    currentValue = new ComputedField =>
      return unless data = options.load()

      # We look if we have the value field (we can't do data.value?
      # because it can just carry null value, but the key is there).
      if 'value' of data
        # This is a raw value, clean up if we previously had templates/nodes.
        cleanTemplate()
        cleanNode()

        # Simply return the value.
        data.value

      # Note: We allow templateId for backwards compatibility.
      else if data.template or data.templateId
        cleanNode()
        
        if data.template?.data
          return templateNode if templateNode

          # We create a node similarly to how the template prepares it, but we load directly the embedded data instead
          # of needing to query template document. Note that we reset the address hierarchy from here on out to match
          # the address relative to the template.
          templateNode = Tracker.nonreactive => new AM.Hierarchy.Node
            templateClass: options.templateClass
            template: _id: data.template.id
            address: new AM.Hierarchy.Address
            load: new ComputedField => data.template.data
            save: =>
              throw new AE.InvalidOperationException "You cannot modify published versions of templates."

          templateNode
  
        else
          # Return the template document's root node (it will be null until the subscription kicks in).
          templateId = data.templateId or data.template.id

          options.templateClass.documents.findOne(templateId)?.node

      else if data.node
        cleanTemplate()

        # We create a new node if needed (if not, the node's load
        # function will already be dynamically loading new values).
        unless node
          # We allow sending in already instantiated nodes.
          if data.node instanceof AM.Hierarchy.Node
            node = data.node

          else
            # In general we instantiate a node that will return the
            # plain node data. We only want to react to changes in the data.
            Tracker.nonreactive =>
              node = new AM.Hierarchy.Node _.extend {}, options,
                address: options.address.nodeChild()
                load: new ComputedField =>
                  # We dynamically load the value from the parent so that we
                  # don't have to keep re-creating nodes whenever data changes.
                  options.load()?.node
                ,
                  EJSON.equals
                ,
                  true

        # Return the node.
        node

      else if data.type
        # This is a placeholder node that doesn't have a value yet, but it
        # knows what type it will be. Used in fields with dynamic types.

      else
        console.error "Data field", options.address.string(), "got value", data
        console.trace()
        throw new AE.InvalidOperationException "Data field is not in correct format."
    ,
      EJSON.equals
    ,
      true

    # We want the hierarchy field to behave as a getter/setter.
    field = (value) ->
      # Is this a setter? We compare to undefined and not just use
      # value? since we want to be able to set the value null to the field.
      if value isnt undefined
        storedValue = AM.Hierarchy.convertObjectToStoredValue value

        # Add meta data if we have it set.
        _.extend storedValue, metaData if metaData

        # Send the new structure to the save function.
        options.save options.address.string(), storedValue

        return

      # No, this is a getter, so load the data.
      currentValue()

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf field, @constructor.prototype

    # Store options on field.
    field.options = options
    
    # Reports if this field has done loading its data.
    field.ready = ->
      # Depend on value change.
      value = currentValue()
      
      # If we have a node, make sure the node is ready.
      return value.ready() if value instanceof AM.Hierarchy.Node
      
      true

    # Gets a node, even if the data for it does not exist yet.
    # This allows us to save at locations that haven't been set yet.
    field.getNode = ->
      # First try to normally get the field value.
      resultNode = field()

      if resultNode instanceof AM.Hierarchy.Node
        # We have a node so just return it.
        resultNode

      else if not resultNode
        # We return a placeholder node, that doesn't load any data (since it's not present).
        placeholderNode ?= new AM.Hierarchy.Node _.extend {}, options,
          address: options.address.nodeChild()
          load: => null

        placeholderNode

      else
        # We should only get a node or undefined. If we're getting a value it's probably an addressing error.
        throw new AE.ArgumentException "The data at this address is a terminal value, not a node."

    # Setting meta data ensures future saves will have the meta data fields present.
    field.setMetaData = (newMetaData) ->
      metaData = newMetaData

    # Saving meta data writes it immediately, modifying any data currently in the field.
    field.saveMetaData = (newMetaData) ->
      return unless metaData = newMetaData

      data = options.load() or {}

      # Add meta data if we have it set.
      _.extend data, metaData

      # Send the new structure to the save function.
      options.save options.address.string(), data

    field.clear = ->
      if metaData
        # Replace the field with just the meta data.
        options.save options.address.string(), metaData

      else
        # Remove the data to get a clear state.
        field.remove()

    field.remove = ->
      # We save null as the value, which will unset the field on the server.
      options.save options.address.string(), null

    field.destroy = ->
      currentValue.stop()
      cleanTemplate()
      cleanNode()
      placeholderNode?.destroy()

    field.isTemplate = ->
      options.load()?.templateId

    # Return the field getter/setter function (return must be explicit).
    return field
