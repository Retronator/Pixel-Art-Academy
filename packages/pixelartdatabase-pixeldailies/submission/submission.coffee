AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.PixelDailies.Submission extends AM.Document
  @id: -> 'PixelArtDatabase.PixelDailies.Submission'

  # time: time when this submission was posted
  # theme: closest matching theme we believe this submission was for
  #   _id
  #   hashtags
  # text: tweet text posted by the user
  # images: list of images posted with this submission
  #   animated: boolean if this was an animated GIF
  #   imageUrl: url of the image
  #   videoUrl: url of the video if animated
  # tweetUrl: url of the tweet with this submission
  # user: the user who posted the submission
  #   name: name of the user
  #   screenName: username of the user
  # favoritesCount: how many favorites this tweet has
  # tweetData: raw data of the submission tweet
  # processingError: string identifying any processing issues
  @Meta
    name: @id()
    fields: =>
      theme: @ReferenceField PADB.PixelDailies.Theme, ['hashtags'], false

  @ProcessingError:
    NoThemeMatch: 'No theme match.'
    NoImages: 'No images.'

  # Subscriptions

  @forTheme: @subscription 'forTheme'
