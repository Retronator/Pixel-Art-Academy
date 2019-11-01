AE = Artificial.Everywhere
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
    location = (value, valueIsRaw) ->
      # Get field at this location.
      field = getField()

      # Delegate the get/set.
      field value, valueIsRaw

    location.field = getField

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf location, @constructor.prototype

    # Store options on location.
    location.options = options

    location.ready = ->
      # Location is ready when its field is ready.
      field = getField()
      field.ready()

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

    # Setting meta data ensures future saves will have the meta data fields present.
    location.setMetaData = (newMetaData) ->
      metaData = newMetaData

    # Saving meta data writes it immediately, modifying any data currently in the field.
    location.saveMetaData = (newMetaData) ->
      metaData = newMetaData

      # Immediately write this meta data to the field at this location.
      field = getField()
      field.saveMetaData metaData

    # Add extra information that is to be used to create a template out of this location.
    location.setTemplateMetaData = (newTemplateMetaData) ->
      templateMetaData = newTemplateMetaData

    # Sets this field to inherit data from a template.
    location.setTemplate = (templateId, versionIndex) ->
      field = location.field()
      
      template =
        id: templateId
        
      template.version = versionIndex if versionIndex?

      # Add field meta data.
      data = _.extend {template}, metaData

      field.options.save field.options.address.string(), data

    # Replaces just the template in this field, preserving all meta data.
    location.replaceTemplate = (templateId, versionIndex) ->
      field = location.field()
      node = field()
      throw new AE.InvalidOperationException "Location doesn't hold a template." unless node.template

      data = field.options.load()

      data.template = id: templateId
      data.template.version = versionIndex if versionIndex?

      # Clean old template format.
      delete data.templateId

      field.options.save field.options.address.string(), data

    # Embeds the template if it's missing denormalized data.
    location.embedTemplate = (defaultToLatestVersion) ->
      field = location.field()
      node = field()
      throw new AE.InvalidOperationException "Location doesn't hold a template." unless node.template

      # Make sure we have a published template.
      liveTemplate = LOI.Character.Part.Template.documents.findOne node.template._id
      return unless liveTemplate?.latestVersion

      # See if we have a version specified.
      targetVersion = node.template.version

      # Default to latest version if requested.
      targetVersion ?= liveTemplate.latestVersion.index if defaultToLatestVersion

      return unless targetVersion

      location.replaceTemplate node.template._id, targetVersion

    # Clears the location if a template doesn't exist.
    location.cleanMissingTemplate = (remove) ->
      field = location.field()
      node = field()
      throw new AE.InvalidOperationException "Location doesn't hold a template." unless node.template

      # If we have a published template we don't have anything to clean.
      return if LOI.Character.Part.Template.documents.findOne(node.template._id)?.latestVersion

      # Published template was not published so we should clean this location.
      if remove
        location.remove()

      else
        location.clear()

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
    location.unlinkTemplate = ->
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
      
    location.publishTemplate = ->
      field = location.field()
      node = field()
      throw new AE.InvalidOperationException "Location doesn't hold a template." unless node.template
      
      templateId = node.template._id
      field.options.templateClass.publish templateId, (error, versionIndex) =>
        if error
          console.error error
          return

        # Update this node to the newly published template version.
        location.setTemplate templateId, versionIndex
        
    location.revertTemplate = ->
      field = location.field()
      node = field()
      throw new AE.InvalidOperationException "Location doesn't hold a template." unless node.template

      templateId = node.template._id
      field.options.templateClass.revert templateId, (error, versionIndex) =>
        if error
          console.error error
          return

        location.setTemplate templateId, versionIndex

    defaultCanUpgradeComparator = (embeddedTemplate, liveTemplate) ->
      embeddedTemplate?.version < liveTemplate?.latestVersion?.index

    location.canUpgradeTemplate = (canUpgradeComparator = defaultCanUpgradeComparator) ->
      field = location.field()
      node = field()
      throw new AE.InvalidOperationException "Location doesn't hold a template." unless node.template

      return unless liveTemplate = field.options.templateClass.documents.findOne node.template.id

      canUpgradeComparator node.template, liveTemplate

    location.upgradeTemplate = (canUpgradeComparator = defaultCanUpgradeComparator) ->
      field = location.field()
      node = field()
      throw new AE.InvalidOperationException "Location doesn't hold a template." unless node.template

      liveTemplate = field.options.templateClass.documents.findOne node.template.id
      throw new AE.InvalidOperationException "Template doesn't have a published version yet." unless liveTemplate?.latestVersion
      throw new AE.InvalidOperationException "Template is already at the latest version." unless canUpgradeComparator node.template, liveTemplate

      location.replaceTemplate node.template.id, liveTemplate.latestVersion.index

    location.usedTemplates = ->
      field = location.field()
      return [] unless node = field()

      usedTemplates = []

      collectTemplates = (data) =>
        for key, value of data
          if key is 'template'
            usedTemplates.push value

          else if _.isObject value
            collectTemplates value

      collectTemplates node.data()

      usedTemplates

    location.includesUpgradableTemplates = (canUpgradeComparator = defaultCanUpgradeComparator) ->
      for usedTemplate in location.usedTemplates()
        continue unless liveTemplate = LOI.Character.Part.Template.documents.findOne usedTemplate.id
        return true if canUpgradeComparator usedTemplate, liveTemplate

      false

    location.upgradeTemplates = (canUpgradeComparator = defaultCanUpgradeComparator) ->
      upgradeTemplates = (location) ->
        return unless node = location()

        # See which fields this node has.
        for fieldName, field of node.data().fields
          fieldLocation = location.child fieldName
          continue unless fieldNode = fieldLocation()

          if fieldNode.template
            # See if the template's version is the latest.
            liveTemplate = LOI.Character.Part.Template.documents.findOne fieldNode.template.id
            continue unless liveTemplate?.latestVersion

            if canUpgradeComparator fieldNode.template, liveTemplate
              fieldLocation.replaceTemplate fieldNode.template.id, liveTemplate.latestVersion.index

          else if fieldNode instanceof AM.Hierarchy.Node
            upgradeTemplates fieldLocation

      # Upgrade all templates inside this location.
      upgradeTemplates location

    location.embedTemplates = (defaultToLatestVersion) ->
      embedTemplates = (location) ->
        return unless node = location()

        # See which fields this node has.
        for fieldName, field of node.data().fields
          fieldLocation = location.child fieldName
          continue unless fieldNode = fieldLocation()

          if fieldNode.template
            # Nothing to do if the data is already there.
            continue if field.template?.data

            # Make sure we have a published template.
            liveTemplate = LOI.Character.Part.Template.documents.findOne fieldNode.template._id
            continue unless liveTemplate?.latestVersion

            # See if we have a version specified.
            targetVersion = fieldNode.template.version

            # Default to latest version if requested.
            targetVersion ?= liveTemplate.latestVersion.index if defaultToLatestVersion

            if targetVersion?
              fieldLocation.replaceTemplate fieldNode.template._id, targetVersion

          else if fieldNode instanceof AM.Hierarchy.Node
            embedTemplates fieldLocation

      # Embed all templates inside this location.
      embedTemplates location

    location.cleanMissingTemplates = (remove) ->
      cleanMissingTemplates = (location) ->
        return unless node = location()

        # See which fields this node has.
        for fieldName, field of node.data().fields
          fieldLocation = location.child fieldName
          continue unless fieldNode = fieldLocation()

          if fieldNode.template
            fieldLocation.cleanMissingTemplate remove

          else if fieldNode instanceof AM.Hierarchy.Node
            cleanMissingTemplates fieldLocation

      # Clean all templates inside this location.
      cleanMissingTemplates location

    location.canUpgrade = (canUpgradeComparator = defaultCanUpgradeComparator) ->
      if location()?.template then location.canUpgradeTemplate canUpgradeComparator else location.includesUpgradableTemplates canUpgradeComparator

    location.upgrade = (canUpgradeComparator = defaultCanUpgradeComparator) ->
      if location()?.template then location.upgradeTemplate canUpgradeComparator else location.upgradeTemplates canUpgradeComparator

    location.embed = (defaultToLatestVersion) ->
      if location()?.template then location.embedTemplate defaultToLatestVersion else location.embedTemplates defaultToLatestVersion

    location.cleanMissing = (remove) ->
      if location()?.template then location.cleanMissingTemplate remove else location.cleanMissingTemplates remove

    # Return the location getter/setter function (return must be explicit).
    return location
