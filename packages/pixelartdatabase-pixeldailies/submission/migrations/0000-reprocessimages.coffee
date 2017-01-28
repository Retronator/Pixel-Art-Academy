PADB = PixelArtDatabase

class Migration extends Document.PatchMigration
  name: "Reprocess images of the submission."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    collection.findEach
      _schema: currentSchema
    ,
      fields:
        tweetData: 1
        processingError: 1
    ,
      (document) =>
        # Make sure the document didn't fail due to no hashtags.
        return if document.processingError is 'No extra hashtag.'

        update =
          $set:
            images: []

        # Get tweet images.
        if document.tweetData.retweeted_status.extended_entities?.media
          for media in document.tweetData.retweeted_status.extended_entities.media
            switch media.type
              when 'photo'
                update.$set.tweetUrl ?= media.url
                update.$set.images.push
                  imageUrl: media.media_url

              when 'animated_gif'
                update.$set.tweetUrl ?= media.url
                update.$set.images.push
                  animated: true
                  imageUrl: media.media_url
                  videoUrl: media.video_info.variants[0].url

        unless update.$set.images.length
          update =
            $set:
              processingError: 'No images.'
              
        update.$set._schema = newSchema

        updated = collection.update document, update

        count += updated

    counts = super
    counts.migrated += count
    counts.all += count
    counts

PADB.PixelDailies.Submission.addMigration new Migration()
