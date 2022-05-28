LOI = LandsOfIllusions
RS = Retronator.Store

class Migration extends Document.MajorMigration
  name: "Remove fixed cluster attachment."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
    ,
      (document) =>
        documentChanged = false
        
        for object in document.objects when object
          for layer in object.layers when layer
            for index, cluster of layer.clusters
              # Change Fixed attachment to Contact.
              if cluster.properties?.attachment is 'Fixed'
                cluster.properties.attachment = 'Contact'
                documentChanged = true

        if documentChanged
          count += collection.update _id: document._id,
            $set:
              objects: document.objects
              _schema: newSchema

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Assets.Mesh.addMigration new Migration()
