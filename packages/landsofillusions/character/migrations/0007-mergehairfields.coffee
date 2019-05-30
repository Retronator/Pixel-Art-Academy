LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Merge hair and hair behind fields."

  forward: (document, collection, currentSchema, newSchema) ->
    count = 0

    collection.findEach
      $and: [
        _schema: currentSchema
        $or: [
          'avatar.body.node.fields.head.node.fields.hair': $exists: true
        ,
          'avatar.body.node.fields.head.node.fields.hairBehind': $exists: true
        ]
      ]
    ,
      (document) =>
        hairFields = _.values document.avatar.body.node.fields.head.node.fields.hair?.node.fields
        hairBehindFields = _.values document.avatar.body.node.fields.head.node.fields.hairBehind?.node.fields

        setRegion = (fields, region) =>
          for fieldOrder, field of fields when field.type is 'Avatar.Body.Hair' and field.node?.fields?.shapes?.node?.fields
            for shapeOrder, shape of field.node.fields.shapes.node.fields when shape.node?.fields and shape.type is 'Avatar.Body.HairShape'
              shape.node.fields.region ?= value: region

        setRegion hairFields, 'HairFront'
        setRegion hairBehindFields, 'HairBehind'

        newHairFields = {}

        for hairNode, index in _.flatten [hairBehindFields, hairFields] when hairNode
          newHairFields[index] = hairNode

        count += collection.update _id: document._id,
          $set:
            'avatar.body.node.fields.head.node.fields.hair.node.fields': newHairFields
            _schema: newSchema
          $unset:
            'avatar.body.node.fields.head.node.fields.hairBehind': true

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Character.addMigration new Migration()
