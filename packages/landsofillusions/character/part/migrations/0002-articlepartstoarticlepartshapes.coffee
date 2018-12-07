LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Creating article part shapes out of article parts."

  forward: (document, collection, currentSchema, newSchema) =>
    count = collection.update
      _schema: currentSchema
      type: 'Avatar.Outfit.ArticlePart'
      'data.fields.front': $exists: true
    ,
      $set:
        type: 'Avatar.Outfit.ArticlePartShape'
        _schema: newSchema
    ,
      multi: true

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) =>
    count = collection.update
      _schema: currentSchema
      type: 'Avatar.Outfit.ArticlePartShape'
    ,
      $set:
        type: 'Avatar.Outfit.ArticlePart'
        _schema: oldSchema
    ,
      multi: true

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Character.Part.Template.addMigration new Migration()
