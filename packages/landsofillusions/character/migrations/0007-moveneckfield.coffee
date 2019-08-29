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

        $set = _schema: newSchema

        # Only move the neck field if the torso isn't a template (in that case the neck field will come from there).
        unless document.avatar.body.node.fields.torso?.template or document.avatar.body.node.fields.torso?.templateId
          $set['avatar.body.node.fields.torso.node.fields.neck'] = neck

        count += collection.update _id: document._id,
          $set: $set
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
