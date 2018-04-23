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
            memory:
              _id: document.conversation._id
            type: LOI.Memory.Actions.Say.type
            content:
              say:
                text: document.text
            # Set that all existing conversations happened at the HQ Cafe in the present.
            timelineId: LandsOfIllusions.TimelineIds.Present
            locationId: Retronator.HQ.Cafe.id()
            _schema: newSchema
          $unset:
            conversation: true
            text: true

    counts = super
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
    ,
      (document) =>
        count += collection.update _id: document._id,
          $set:
            text: document.content.say.text
            conversation:
              _id: document.memory._id
            _schema: oldSchema
          $unset:
            memory: true
            type: true
            content: true
            timelineId: true
            locationId: true

    counts = super
    counts.migrated += count
    counts.all += count
    counts

LOI.Memory.Action.addMigration new Migration()
