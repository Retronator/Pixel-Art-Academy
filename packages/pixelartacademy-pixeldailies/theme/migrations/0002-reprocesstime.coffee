PAA = PixelArtAcademy

class Migration extends Document.PatchMigration
  name: "Reprocesses the theme time from previous date value to actual time."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
    ,
      fields:
        tweetData: 1
    ,
      (document) =>
        updated = collection.update document,
          $set:
            time: new Date document.tweetData.created_at
            _schema: newSchema

        count += updated

    counts = super
    counts.migrated += count
    counts.all += count
    counts

PAA.PixelDailies.Theme.addMigration new Migration()
