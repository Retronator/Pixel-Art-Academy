PAA = PixelArtAcademy

class Migration extends Document.MajorMigration
  name: "Change to memories."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
      conversations: $exists: true
    ,
      (document) =>
        # Change conversations to memories.
        memories = (_id: conversationId for conversationId in document.conversations)

        count += collection.update
          _id: document._id
        ,
          $set: {memories}
          $unset:
            conversations: true

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
      memories: $exists: true
    ,
      (document) =>
        # Change memories to conversations.
        conversations = (memory._id for memory in document.memories)

        count += collection.update
          _id: document._id
        ,
          $set: {conversations}
          $unset:
            memories: true
            
    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

PAA.Practice.CheckIn.addMigration new Migration()
