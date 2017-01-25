AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.PixelDailies.Theme extends AM.Document
  @id: -> 'PixelArtDatabase.PixelDailies.Theme'
  # time: time when this theme was posted
  # hashtags: array of theme hashtags to identify submissions
  # text: tweet text posted by @Pixel_Dailies
  # tweetData: raw data of the theme tweet
  # processingError: string identifying any processing issues
  @Meta
    name: @id()

  @ProcessingError:
    MissingPixelDailiesHashtag: 'Missing #pixel_dailies hashtag.'
    NoExtraHashtag: 'No extra hashtag.'

  # Subscriptions

  @forDateRange: @subscription 'forDateRange'
