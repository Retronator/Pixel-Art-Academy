LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Move authors to profile ID."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
    ,
      (document) =>
        modifier =
          $set:
            _schema: newSchema
          $unset:
            authors: true
          
        if profileId = document.authors?[0]?._id
          modifier.$set.profileId = profileId
        
        count += collection.update _id: document._id, modifier

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
    ,
        modifier =
          $set:
            _schema: oldSchema
          $unset:
            profileId: true
  
        if authorId = document.profileId
          modifier.$set.authors = [_id: authorId]
  
        count += collection.update _id: document._id, modifier

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Assets.Audio.addMigration new Migration()
LOI.Assets.Bitmap.addMigration new Migration()
LOI.Assets.Mesh.addMigration new Migration()
LOI.Assets.Sprite.addMigration new Migration()
