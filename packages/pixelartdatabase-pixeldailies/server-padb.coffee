PADB = PixelArtDatabase

class PADB.PixelDailies extends PADB.PixelDailies
  # Archives the submission into the database.
  @archiveSubmission: (submission) ->
    # First we need to see if this is a valid submission.
    return if submission.processingError

    # Find the twitter profile.
    profile = PADB.Profile.get
      platformType: PADB.Profile.PlatformTypes.Twitter
      username: submission.user.screenName
      
    # Create an artwork out of each image in the submission.
    for image in submission.images
      # Find type of the image.
      type = if image.animated then PADB.Artwork.Types.AnimatedImage else PADB.Artwork.Types.Image

      # Create representations of this image.
      representations = [
        type: PADB.Artwork.RepresentationTypes.Image
        url: image.imageUrl
      ,
        type: PADB.Artwork.RepresentationTypes.Post
        url: submission.tweetUrl
      ]

      if image.animated
        representations.push
          type: PADB.Artwork.RepresentationTypes.Video
          url: image.videoUrl

      # Set the artist from the profile.
      authors = [
        _id: profile.artist._id
      ]

      # Create and insert the artwork.
      artwork =
        type: type
        completionDate: submission.time
        authors: authors
        representations: representations

      # Find if we already have an artwork by searching for the image url in this tweet.
      existing = PADB.Artwork.documents.findOne 'representations.url': image.imageUrl

      if existing
        PADB.Artwork.documents.update existing._id, artwork

      else
        PADB.Artwork.documents.insert artwork
