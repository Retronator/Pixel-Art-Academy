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
    triggers: =>
      updateUserStatistics: @Trigger ['favoritesCount', 'user', 'processingError'], (submission, oldSubmission) =>
        # Update statistics of both users.
        screenNames = _.uniq [submission?.user?.screenName, oldSubmission?.user?.screenName]
        screenNames = _.without screenNames, undefined

        @updateUserStatistics screenName for screenName in screenNames

      favoritesCountUpdated: @Trigger ['theme._id', 'favoritesCount', 'processingError'], (submission, oldSubmission) =>
        # Update the themes of both submissions.
        themeIds = _.uniq [submission?.theme?._id, oldSubmission?.theme?._id]
        themeIds = _.without themeIds, undefined

        PADB.PixelDailies.Theme.updateSubmissions themeId for themeId in themeIds

  @ProcessingError:
    NoThemeMatch: 'No theme match.'
    NoImages: 'No images.'
    ImagesNotFound: 'Images not found.'

  # Subscriptions

  @forTheme: @subscription 'forTheme'

  @updateUserStatistics: (screenName) ->
    # Find the twitter profile.
    profile = PADB.Profile.Providers.Twitter.getByScreenName screenName

    submissions = @documents.find(
      'user.screenName': new RegExp screenName, 'i'
      processingError:
        $ne: PADB.PixelDailies.Submission.ProcessingError.NoImages
    ,
      fields:
        tweetData: 0
    ).fetch()

    statisticsByYear = {}

    for submission in submissions
      year = submission.time.getFullYear()
      statisticsByYear[year] ?= {}
      statistics = @_prepareCumulativeStatistics statisticsByYear[year]

      statistics.submissionsCount++
      statistics.favoritesCount += submission.favoritesCount
      for image in submission.images when image.animated
        statistics.animatedSubmissionsCount++
        break

      @_calculateDirectStatistics statistics

    overallStatistics = @_prepareCumulativeStatistics()

    for year, statistics of statisticsByYear
      for cumulativeProperty in ['submissionsCount', 'favoritesCount', 'animatedSubmissionsCount']
        overallStatistics[cumulativeProperty] += statistics[cumulativeProperty]

    @_calculateDirectStatistics overallStatistics

    PADB.Profile.documents.update profile._id,
      $set:
        pixelDailies:
          statisticsByYear: statisticsByYear
          statistics: overallStatistics

  @_prepareCumulativeStatistics: (statistics = {}) ->
    statistics.submissionsCount ?= 0
    statistics.favoritesCount ?= 0
    statistics.animatedSubmissionsCount ?= 0

    statistics

  @_calculateDirectStatistics: (statistics) ->
    statistics.animatedSubmissionRatio = statistics.animatedSubmissionsCount / statistics.submissionsCount
