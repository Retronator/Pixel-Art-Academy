LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Make outfit articles use the new article part shapes."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    templatesCollection = new DirectCollection 'LandsOfIllusions.Character.Part.Templates'

    collection.findEach
      _schema: currentSchema
      type: 'Avatar.Outfit.Article'
      'data.fields.parts.node.fields': $exists: true
    ,
      (document) =>
        changed = false

        for order, field of document.data.fields.parts.node.fields
          if field.templateId
            # Find linked template and see if it's actually an article part.
            template = templatesCollection.findOne _id: field.templateId
            continue if template.type is field.type

            newField =
              type: 'Avatar.Outfit.ArticlePartShape'
              templateId: field.templateId

          else if field.node?.fields?.front
            newField =
              type: 'Avatar.Outfit.ArticlePartShape'
              node: field.node

          else
            continue

          # The template is a shape, so we want to have a part that includes the shape.
          document.data.fields.parts.node.fields[order] =
            type: 'Avatar.Outfit.ArticlePart'
            node:
              fields:
                region:
                  value: 'Torso'
                shapes:
                  node:
                    fields:
                      0: newField
                      
          changed = true
          
        return unless changed
        
        document._schema = newSchema

        count += collection.update _id: document._id, document

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Character.Part.Template.addMigration new Migration()
