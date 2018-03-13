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
            type: LOI.Memory.Action.Types.Say
            content:
              say:
                text: document.text
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
          $unset:
            memory: true
            type: true
            content: true

    counts = super
    counts.migrated += count
    counts.all += count
    counts

LOI.Memory.Action.addMigration new Migration()
