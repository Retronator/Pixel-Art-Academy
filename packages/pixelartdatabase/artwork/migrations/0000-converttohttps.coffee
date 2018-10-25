PADB = PixelArtDatabase

class Migration extends Document.PatchMigration
  name: "Convert Twitter representation URLs to https."

  forward: (document, collection, currentSchema, newSchema) ->
    count = @rename document, collection, currentSchema, newSchema, 'http://pbs.twimg.com', 'https://pbs.twimg.com'

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, newSchema) ->
    count = @rename document, collection, currentSchema, newSchema, 'https://pbs.twimg.com', 'http://pbs.twimg.com'

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  rename: (document, collection, currentSchema, newSchema, oldPattern, newPattern) ->
    count = 0

    collection.findEach
      _schema: currentSchema
      'representations.url':
        $regex: oldPattern
    ,
      fields:
        'representations': 1
    ,
      (document) =>
        for representation in document.representations
          representation.url = representation.url.replace oldPattern, newPattern

        updated = collection.update
          _id: document._id
        ,
          $set:
            representations: document.representations
            _schema: newSchema

        count += updated

    count

PADB.Artwork.addMigration new Migration()
