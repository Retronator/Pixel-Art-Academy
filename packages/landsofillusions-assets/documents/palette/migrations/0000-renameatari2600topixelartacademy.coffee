LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Rename Atari 2600 palette to Pixel Art Academy."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
      name: 'Atari 2600'
    ,
      (document) =>
        count += collection.update _id: document._id,
          $set:
            name: 'Pixel Art Academy'

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
      name: 'Pixel Art Academy'
    ,
      (document) =>
        count += collection.update _id: document._id,
          $set:
            name: 'Atari 2600'

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Assets.Palette.addMigration new Migration()
