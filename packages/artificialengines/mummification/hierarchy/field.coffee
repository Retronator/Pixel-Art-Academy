AM = Artificial.Mummification

class AM.Hierarchy.Field
  # For data passed to the field, refer to template document structure.
  constructor: (options) ->
    templateSubscription = null
    node = null

    cleanTemplate = ->
      templateSubscription?.stop()

    cleanNode = ->
      node?.destroy()

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
          # Let's take a look what kind of value we're setting.
          if value instanceof AM.Hierarchy.Template
            saveValue =
              templateId: value._id
              
          else if value instanceof AM.Hierarchy.Node
            # Just copy node's data.
            saveValue =
              node: value.data()

          else if _.isObject value
            saveValue =
              node: AM.Hierarchy.convertObjectToStoredValue value

          else
            saveValue =
              value: value

          # Send the new structure to the save function.
          options.save options.address.string(), saveValue

        return

      # No, this is a getter, so load the data.
      return unless data = options.load()

      if data.value
        # This is a raw value, clean up if we previously had templates/nodes.
        cleanTemplate()
        cleanNode()
        
        # Simply return the value.
        data.value

      else if data.templateId
        cleanNode()
        
        # Subscribe to this template.
        templateSubscription = AM.Hierarchy.Template.forId.subscribe data.templateId

        # Return the template document's root node (it will be null until the subscription kicks in).
        AM.Hierarchy.Template.documents.findOne(data.templateId)?.node

      else if data.node
        cleanTemplate()
        
        # We create a new node if needed (if not, the node's load 
        # function will already be dynamically loading new values).
        node ?= new AM.Hierarchy.Node
          address: options.address.nodeChild()
          load: =>
            # We dynamically load the value from the parent so that we 
            # don't have to keep re-creating nodes whenever data changes.
            options.load().node
          save: options.save
            
        # Return the node.
        node

    field.destroy = ->
      cleanTemplate()
      cleanNode()

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf field, @constructor.prototype

    # Return the field getter/setter function (return must be explicit).
    return field
