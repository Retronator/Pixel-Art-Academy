AM = Artificial.Mummification

# This represents a location somewhere in the hierarchy and is used to get/set value at that location.
class AM.Hierarchy.Location
  constructor: (options) ->
    # We start at the top of the hierarchy if no address is given.
    options.address ?= ''
    metaData = null
    templateMetaData = null

    getField = ->
      # We need to traverse from the root of the hierarchy down on each get/set
      # because we never know which parts are object nodes and which templates. 
      addressParts = options.address.split '.'
      [addressPartsToTargetField..., targetField] = addressParts

      if targetField
        # We have a name of the last field that we want to get/set, so transverse the nodes to that field.
        node = options.rootField.getNode()

        for addressPart in addressPartsToTargetField
          field = node.field addressPart
          node = field.getNode()

        # We've reached the end of the chain, so we can access the targetField (if we even got the node).
        result = node.field targetField

      else
        # We're at the top of the hierarchy so we return directly the root field.
        result = options.rootField
       
      # Before we return the field, set its meta data.
      result.setMetaData metaData
      result

    # We want the hierarchy location to behave as a getter/setter.
    location = (value) ->
      # Get field at this location.
      field = getField()

      # Delegate the get/set.
      field value

    location.field = getField

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf location, @constructor.prototype

    # Store options on location.
    location.options = options

    # Creates a location with the given address below the current location.
    location.child = (address) ->
      prefix = if options.address then "#{options.address}." else ''

      new location.constructor _.extend {}, options,
        address: "#{prefix}#{address}"

    # Creates a location at the given absolute address in this hierarchy.
    location.absoluteAddress = (address) ->
      new location.constructor _.extend {}, options, {address}

    # Removes any data at this location (but preserves meta data/instance).
    location.clear = ->
      location.field().clear()

    # Removes this location completely.
    location.remove = ->
      location.field().remove()

    # Ensure the field in this location has the extra meta data attached.
    location.setMetaData = (newMetaData) ->
      metaData = newMetaData

    # Add extra information that is to be used to create a template out of this location.
    location.setTemplateMetaData = (newTemplateMetaData) ->
      templateMetaData = newTemplateMetaData

    # Sets this field to inherit data from a template.
    location.setTemplate = (templateId) ->
      field = location.field()

      # Add field meta data.
      data = _.extend {templateId}, metaData

      field.options.save field.options.address.string(), data

    # Converts this node into a template.
    location.createTemplate = ->
      field = location.field()
      node = field()
      throw new AE.InvalidOperationException "Location already holds a template." if node.template

      # Get the data we're converting into the template.
      data = node.data()

      # Create the template with this data. We also send our options
      # in case the method implementation needs any of our meta data.
      field.options.templateClass.insert data, templateMetaData, (error, templateId) =>
        if error
          console.error error
          return

        # Turn this node into a template node.
        location.setTemplate templateId

    # Takes the data from the template and converts it into a node in this field.
    location.unlinkTemplate = (templateId) ->
      field = location.field()
      node = field()
      throw new AE.InvalidOperationException "Location doesn't hold a template." unless node.template

      templateData = node.template.data

      # We change the template data into a local node field with associated meta data.
      data = _.extend
        node: templateData
      ,
        metaData

      # We save this using parent's save function and address, not the template's.
      field.options.save field.options.address.string(), data

    # Return the location getter/setter function (return must be explicit).
    return location
