PADB = PixelArtDatabase

class Migration extends Document.PatchMigration
  name: "Convert theme hashtags to lowercase."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
      hashtags:
        $exists: 1
    ,
      fields:
        hashtags: 1
    ,
      (document) =>
        lowercaseHashtags = for hashtag in document.hashtags
          hashtag.toLowerCase()

        updated = collection.update document,
          $set:
            hashtags: lowercaseHashtags
            _schema: newSchema

        count += updated

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

PADB.PixelDailies.Theme.addMigration new Migration()
