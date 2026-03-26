PAA = PixelArtAcademy

class Migration extends Document.MajorMigration
  name: "Change Snake, Invasion, and Pinball project types."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
      type: /^(?!.*\.Project$)/
    ,
      (document) =>
        type = "#{document.type}.Project"
        
        # Remove deprecated character reference field name.
        count += collection.update _id: document._id,
          $set:
            type: type
            _schema: newSchema

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

PAA.Practice.Project.addMigration new Migration()
