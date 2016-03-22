PAA = PixelArtAcademy

class PixelDailiesTheme extends Document
  # date: date when this theme was posted
  # hashtag: theme hashtag to identify submissions
  # text: tweet text posted by @Pixel_Dailies
  # tweetData: raw data of the theme tweet
  # processingError: boolean if the tweet had processing issues due to ambiguity
  @Meta
    name: 'PixelDailiesTheme'

  @ProcessingError:
    MissingPixelDailiesHashtag: 'Missing #pixel_dailies hashtag.'
    NoExtraHashtag: 'No extra hashtag.'
    MultipleExtraHashtags: 'Multiple extra hashtags.'

PAA.PixelDailies.Theme = PixelDailiesTheme
