PAA = PixelArtAcademy

class PixelArtAcademyPixelDailiesTheme extends Document
  # date: date when this theme was posted
  # hashtags: array of theme hashtags to identify submissions
  # text: tweet text posted by @Pixel_Dailies
  # tweetData: raw data of the theme tweet
  # processingError: string identifying any processing issues
  @Meta
    name: 'PixelArtAcademyPixelDailiesTheme'

  @ProcessingError:
    MissingPixelDailiesHashtag: 'Missing #pixel_dailies hashtag.'
    NoExtraHashtag: 'No extra hashtag.'

PAA.PixelDailies.Theme = PixelArtAcademyPixelDailiesTheme
