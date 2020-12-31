PADB = PixelArtDatabase

processTweetText = (tweet) ->
  theme = {}

  # The theme tweets must have a #pixel_dailies and another tag, which is the theme tag.
  hashtags = tweet.entities.hashtags
  if _.contains hashtags, 'pixel_dailies'
    themeHashtags = _.without hashtags, 'pixel_dailies', 'pixelart'

    if themeHashtags.length is 0
      # We don't have anything but the #pixel_dailies hashtag, so flag the error.
      theme.processingError = 'No extra hashtag.'

    else
      theme.hashtags = []
      theme.hashtags.push hashtag.toLowerCase() for hashtag in themeHashtags

  else
    # We don't have the #pixel_dailies hashtag, so flag the error.
    theme.processingError = 'Missing #pixel_dailies hashtag.'

  theme

class Migration extends Document.MajorMigration
  name: "Changing single hashtags to an array."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    # Reprocess the hashtags to extract multiple values. Also get rid of the old multiple hashtags error.
    collection.findEach
      _schema: currentSchema
    ,
      fields:
        _schema: 1
        hashtag: 1
        text: 1
        processingError: 1
    ,
      (document) =>
        set = processTweetText document.tweetData
        set._schema = newSchema

        unset =
          hashtag: 1

        unset.processingError = 1 if document.processingError is 'Multiple extra hashtags.'

        count += collection.update document,
          $set: set
          $unset: unset

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) =>
    count = 0

    # Extract just the first element from hashtags and store it as the single hashtag.
    # If multiple hashtags are found, also set the old error for multiple themes.
    collection.findEach
      _schema: currentSchema
    ,
      fields:
        _schema: 1
        hashtags: 1
    ,
      (document) =>
        set =
          hashtag: document.hashtags[0]
          _schema: oldSchema

        set.processingError = 'Multiple extra hashtags.' if document.hashtags.lenght > 1

        count += collection.update document,
          $set: set
          $unset:
            hashtags: 1

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

PADB.PixelDailies.Theme.addMigration new Migration()
