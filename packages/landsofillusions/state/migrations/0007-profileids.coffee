LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Move from user and character IDs to profile IDs."

  forward: (document, collection, currentSchema, newSchema) ->
    count = 0
  
    collection.findEach
      _schema: currentSchema
      $or: [
        user: $exists: true
      ,
        character: $exists: true
      ]
    ,
      (document) =>
        profileId = document.user?._id or document.character?._id
      
        updated = collection.update
          _id: document._id
        ,
          $set:
            profileId: profileId
            _schema: newSchema
          $unset:
            user: true
            character: true
      
        count += updated
  
    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.GameState.addMigration new Migration()
