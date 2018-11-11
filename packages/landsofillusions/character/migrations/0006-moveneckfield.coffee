LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Move neck avatar field."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
      'avatar.body.node.fields.head.node.fields.neck': $exists: true
    ,
      (document) =>
        neck = document.avatar.body.node.fields.head.node.fields.neck

        count += collection.update _id: document._id,
          $set:
            'avatar.body.node.fields.torso.node.fields.neck': neck
            _schema: newSchema
          $unset:
            'avatar.body.node.fields.head.node.fields.neck': true

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
      'avatar.body.node.fields.torso.node.fields.neck': $exists: true
    ,
      (document) =>
        neck = document.avatar.body.node.fields.torso.node.fields.neck

        count += collection.update _id: document._id,
          $set:
            'avatar.body.node.fields.head.node.fields.neck': neck
            _schema: oldSchema
          $unset:
            'avatar.body.node.fields.torso.node.fields.neck': true

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Character.addMigration new Migration()
