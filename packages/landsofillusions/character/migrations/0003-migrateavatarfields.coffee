LOI = LandsOfIllusions

class Migration extends Document.MajorMigration
  name: "Migrate character avatar fields."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    translationsCollection = new DirectCollection 'ArtificialBabelTranslations'

    collection.findEach
      _schema: currentSchema
    ,
      (document) =>
        # Create the avatar object with character colors.
        avatar =
          color: document.color or hue: 0, shade: 0

        # Move name into a translation document (under global 0 language) for full name.
        characterName = document.name

        nameTranslation =
          _id: Random.id()
          translations:
            text: characterName
            quality: 0
            best:
              text: characterName
              quality: 0
              languageRegion: ''

        translationsCollection.insert nameTranslation

        avatar.fullName =
          _id: nameTranslation._id

        # Add the avatar and remove color and name.
        count += collection.update _id: document._id,
          $set:
            avatar: avatar
            _schema: newSchema
          $unset:
            color: 1
            name: 1

    counts = super
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) =>
    count = 0

    translationsCollection = new DirectCollection 'ArtificialBabelTranslation'

    collection.findEach
      _schema: currentSchema
    ,
      (document) =>
        avatar = document.avatar

        fullNameDocument = translationsCollection.findOne avatar.fullName._id

        count += collection.update _id: document._id,
          $set:
            color: avatar.color
            name: fullNameDocument?.translations?.text or fullNameDocument?.translations?.best?.text or 'Name lost during migration'
          $unset:
            avatar: 1

        translationsCollection.remove _id: avatar.fullName._id

    counts = super
    counts.migrated += count
    counts.all += count
    counts

LOI.Character.addMigration new Migration()
