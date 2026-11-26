PAA = PixelArtAcademy

class Migration extends Document.MajorMigration
  name: "Repair project types skipped before local schema tracking."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    # Older local projects skipped the original migration because they had no schema.
    # Preserve types with Project anywhere, including Chess.Project.TwoDimensional.
    collection.findEach
      _schema: currentSchema
      type: /^(?!.*Project)/
    ,
      (document) =>
        # Add .Project to the type.
        type = "#{document.type}.Project"

        count += collection.update _id: document._id,
          $set:
            type: type
            _schema: newSchema

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

PAA.Practice.Project.addMigration new Migration()
