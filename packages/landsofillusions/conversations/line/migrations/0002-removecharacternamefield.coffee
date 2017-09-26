LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Remove character name field."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
    ,
      (document) =>
        # Remove deprecated character reference field name.
        count += collection.update _id: document._id,
          $unset:
            'character.name': 1

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
        # Set the character reference field name from the avatar full name.
        count += collection.update _id: document._id,
          $set:
            'character.name': document.character.avatar.fullName.translations.best.text
            
    counts = super
    counts.migrated += count
    counts.all += count
    counts

LOI.Conversations.Line.addMigration new Migration()
