AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.PixelDailies.Theme extends AM.Document
  @id: -> 'PixelArtDatabase.PixelDailies.Theme'
  # time: time when this theme was posted
  # hashtags: array of theme hashtags to identify submissions
  # text: tweet text posted by @Pixel_Dailies
  # tweetData: raw data of the theme tweet
  # processingError: string identifying any processing issues
  # submissionsCount: number of total submissions
  # topSubmissions: array of top 10 submissions ordered by favorites count
  #   _id
  #   time
  #   text
  #   user
  #     name
  #     screenName
  #   favoritesCount
  #   images
  #     animated
  #     imageUrl
  #     videoUrl
  @Meta
    name: @id()
    fields: =>
      topSubmissions: [@ReferenceField PADB.PixelDailies.Submission, ['favoritesCount', 'time', 'images', 'text', 'user']]

  @ProcessingError:
    MissingPixelDailiesHashtag: 'Missing #pixel_dailies hashtag.'
    NoExtraHashtag: 'No extra hashtag.'

  # Subscriptions

  @forDateRange: @subscription 'forDateRange'

  # Updates submissions count and top submissions.
  @updateSubmissions: (themeId) ->
    submissionsCount = PADB.PixelDailies.Submission.documents.find('theme._id': themeId).count()

    topSubmissions = PADB.PixelDailies.Submission.documents.find(
      'theme._id': themeId
    ,
      sort:
        favoritesCount: -1
      limit: 10
    ).fetch()

    # Strip out just the IDs.
    topSubmissions = for submission in topSubmissions
      _id: submission._id

    @documents.update themeId,
      $set:
        submissionsCount: submissionsCount
        topSubmissions: topSubmissions
