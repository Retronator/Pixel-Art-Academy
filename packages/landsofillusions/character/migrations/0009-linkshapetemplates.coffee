LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Link shape templates in avatars."

  constructor: ->
    super arguments...

  forward: (document, collection, currentSchema, newSchema) ->
    count = 0

    templateForSpriteId = {}
    templatesCollection = new DirectCollection 'LandsOfIllusions.Character.Part.Templates'

    linkShape = (field) ->
      # Nothing to do if the shape field is already a template.
      return if field.template or field.templateId

      unless field.node?.fields?.front?.node?.fields?.spriteId?.value
        console.warn "Invalid shape field", field
        return

      spriteId = field.node.fields.front.node.fields.spriteId.value

      # Find the template that uses this sprite.
      unless template = templateForSpriteId[spriteId]
        template = templatesCollection.findOne
          'data.fields.front.node.fields.spriteId.value': spriteId

        unless template
          console.warn "Couldn't find a template that uses sprite", spriteId
          return

        templateForSpriteId[spriteId] = template

        unless template.latestVersion
          console.warn "Template does not have a latest version.", template

      # Create a template field.
      field.template =
        id: template._id
        name: template.name.translations?.best?.text

      if template.latestVersion
        _.extend field.template,
          version: template.latestVersion.index
          data: template.latestVersion.data

      delete field.node

    traverseNode = (node) ->
      for property, field of node.fields
        if property is 'shape'
          linkShape field

        else if property is 'shapes'
          for index, arrayField of field.node.fields
            linkShape arrayField

        else if field.node
          traverseNode field.node

    collection.findEach
      $and: [
        _schema: currentSchema
        'avatar.body.node': $exists: true
      ]
    ,
      (document) =>
        # Traverse the avatar body.
        traverseNode document.avatar.body.node

        count += collection.update _id: document._id,
          $set:
            'avatar.body.node': document.avatar.body.node
            _schema: newSchema

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Character.addMigration new Migration()
