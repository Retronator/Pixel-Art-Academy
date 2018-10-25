PADB = PixelArtDatabase

class Migration extends Document.PatchMigration
  name: "Convert image URLs to https."

  forward: (document, collection, currentSchema, newSchema) ->
    count = @rename document, collection, currentSchema, newSchema, /http:/, 'https:'

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, newSchema) ->
    count = @rename document, collection, currentSchema, newSchema, /https:/, 'http:'

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  rename: (document, collection, currentSchema, newSchema, oldPattern, newPattern) ->
    count = 0

    collection.findEach
      _schema: currentSchema
      'images.imageUrl':
        $regex: oldPattern
    ,
      fields:
        'images': 1
    ,
      (document) =>
        for image in document.images
          image.imageUrl = image.imageUrl.replace oldPattern, newPattern

        updated = collection.update
          _id: document._id
        ,
          $set:
            images: document.images
            _schema: newSchema

        count += updated

    count

PADB.PixelDailies.Submission.addMigration new Migration()
