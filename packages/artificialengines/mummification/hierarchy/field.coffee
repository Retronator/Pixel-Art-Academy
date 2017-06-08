AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Hierarchy.Field
  # For data passed to the field, refer to template document structure.
  constructor: (options) ->
    templateSubscription = null
    node = null
    placeholderNode = null

    cleanTemplate = ->
      templateSubscription?.stop()

    cleanNode = ->
      node?.destroy()
      node = null

    # We want the hierarchy field to behave as a getter/setter.
    field = (value) ->
      # Is this a setter? We compare to undefined and not just use
      # value? since we want to be able to set the value null to the field.
      if value isnt undefined
        # Do we even need to do any change?
        oldValue = field()

        # We need to rewrite the field if the value changed (and with objects
        # we never know if they were internally changed, so we do it always).
        if value isnt oldValue or _.isObject(value)
          storedValue = AM.Hierarchy.convertObjectToStoredValue value

          # Send the new structure to the save function.
          options.save options.address.string(), storedValue

        return

      # No, this is a getter, so load the data.
      return unless data = options.load()

      if data.value?
        # This is a raw value, clean up if we previously had templates/nodes.
        cleanTemplate()
        cleanNode()
        
        # Simply return the value.
        data.value

      else if data.templateId
        cleanNode()
        
        # Subscribe to this template.
        templateSubscription = options.templateClass.forId.subscribe data.templateId

        # Return the template document's root node (it will be null until the subscription kicks in).
        options.templateClass.documents.findOne(data.templateId)?.node

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
                load: =>
                  # We dynamically load the value from the parent so that we
                  # don't have to keep re-creating nodes whenever data changes.
                  options.load().node

        # Return the node.
        node

      else
        console.error "Data field", options.address.string(), "got value", data
        console.trace()
        throw new AE.InvalidOperationException "Data field is not in correct format."

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf field, @constructor.prototype

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

    # Store options on field.
    field.options = options

    field.destroy = ->
      cleanTemplate()
      cleanNode()
      placeholderNode?.destroy()

    # Return the field getter/setter function (return must be explicit).
    return field
