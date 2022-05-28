LOI = LandsOfIllusions
RS = Retronator.Store

class Migration extends Document.MajorMigration
  name: "Capitalize constants."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
    ,
      (document) =>
        documentChanged = false
        
        for object in document.objects when object
          # Capitalize the first letter of the solver.
          if object.solver?.type
            object.solver.type = _.upperFirst object.solver.type
            documentChanged = true
          
          for layer in object.layers when layer
            for index, cluster of layer.clusters
              # Capitalize the first letter of the attachment.
              if cluster.properties?.attachment
                cluster.properties.attachment = _.upperFirst cluster.properties.attachment
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

  backward: (document, collection, currentSchema, oldSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
    ,
      (document) =>
        documentChanged = false
        
        for object in document.objects when object
          # Lower case the first letter of the solver.
          if object.solver?.type
            object.solver.type = _.lowerFirst object.solver.type
            documentChanged = true
          
          for layer in object.layers when layer
            for index, cluster of layer.clusters
              # Lower case the first letter of the attachment.
              if cluster.properties?.attachment
                cluster.properties.attachment = _.lowerFirst cluster.properties.attachment
                documentChanged = true

        if documentChanged
          count += collection.update _id: document._id,
            $set:
              objects: document.objects
              _schema: oldSchema

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Assets.Mesh.addMigration new Migration()
