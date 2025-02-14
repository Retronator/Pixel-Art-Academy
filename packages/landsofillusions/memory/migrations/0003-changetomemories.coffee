LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Change to memories."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
    ,
      (document) =>
        count += collection.update _id: document._id,
          $set:
            # Set that all existing conversations happened at the HQ Cafe in the present.
            timelineId: LandsOfIllusions.TimelineIds.Present
            locationId: Retronator.HQ.Cafe.id()
          $unset:
            lines: true

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Memory.addMigration new Migration()
