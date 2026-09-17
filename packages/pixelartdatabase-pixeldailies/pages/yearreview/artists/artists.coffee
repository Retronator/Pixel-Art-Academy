AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Artists extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Artists'

  @title: (options) ->
    "Retronator // Top Pixel Dailies #{options.year}: Artists"

  @description: (options) ->
    "The best artists from the Pixel Dailies community in #{options.year}."

  @SortingParameters:
    FavoritesCount: 'pixelDailies.statisticsByYear.{{year}}.favoritesCount'
    SubmissionsCount: 'pixelDailies.statisticsByYear.{{year}}.submissionsCount'
    FollowersCount: 'followersCount'

  # Subscriptions
  
  @highestRanked: new AB.Subscription
    name: "#{@componentName()}.highestRanked"
    query: (sortingParameter, year, limit) =>
      sortingParameter = sortingParameter.replace '{{year}}', year

      profilesCursor = PADB.Profile.documents.find
        "pixelDailies.statisticsByYear.#{year}":
          $exists: true
      ,
        sort:
          "#{sortingParameter}": -1
        limit: limit

      profiles = profilesCursor.fetch()

      yearRange = new AE.DateRange year: year

      submissionsQuery =
        processingError: PADB.PixelDailies.Pages.YearReview.Helpers.displayableSubmissionsCondition

      yearRange.addToMongoQuery submissionsQuery, 'time'

      submissionIds = for profile in profiles
        submissionsQuery['user.screenName'] = new RegExp profile.username, 'i'

        # Find the most favorites submission for this user.
        submission = PADB.PixelDailies.Submission.documents.findOne submissionsQuery,
          sort:
            favoritesCount: -1

        submission?._id

      submissionIds = _.without submissionIds, undefined

      submissionsCursor = PADB.PixelDailies.Submission.documents.find
        _id:
          $in: submissionIds

      [profilesCursor, submissionsCursor]

  mixins: -> [@infiniteScroll, @retireMissingSubmissions]

  constructor: ->
    super arguments...

    @infiniteScroll = new PADB.PixelDailies.Pages.YearReview.Components.Mixins.InfiniteScroll step: 10
    @retireMissingSubmissions = new PADB.PixelDailies.Pages.YearReview.Components.Mixins.RetireMissingSubmissions @

    @sortingParameter = new ReactiveField @constructor.SortingParameters.FavoritesCount

    @videoManager = new PADB.Components.VideoManager
      onLoadError: (sourceUrl) =>
        @retireMissingSubmissions.retireMissingSubmissionForResourceUrl sourceUrl

  onCreated: ->
    super arguments...

    @autorun (computation) =>
      @constructor.highestRanked.subscribe @, @sortingParameter(), @year(), @infiniteScroll.limit()

    # Prepare top user's artworks.
    @profiles = new ComputedField =>
      # Show previous results if available to avoid flickering.
      return @_cachedProfiles unless @subscriptionsReady()

      [profilesCursor, submissionsCursor] = @constructor.highestRanked.query @sortingParameter(), @year(), @infiniteScroll.limit()

      profiles = profilesCursor.fetch()

      # Add ranks.
      for profile, index in profiles
        profile.rank = index + 1

      # Cache results so we can show them while we're switching sorting parameters.
      @_cachedProfiles = profiles

      profiles

    # Update current count for infinite scroll.
    @autorun (computation) =>
      @infiniteScroll.updateCount @profiles()?.length or 0

  onRendered: ->
    super arguments...

    @profileVisibilityTracker = new AM.ElementVisibilityTracker @,
      elements: => @$('.profile')
      scrollParent: window
      viewportHeightDistance: 1
      elementIdentityAndData: (profileElement) =>
        $profile = $(profileElement)
        profile = Blaze.getData profileElement
        profileKey = profile?._id or profile?.username
        $color = $profile.find('.color')
        video = $profile.find('video')[0]
        videoUrl = Blaze.getData(video)?.videoUrl if video

        identity: [profileKey, $color[0], video, videoUrl]
        data:
          $color: $color
          video: video
          videoUrl: videoUrl

      visible: (visibilityInfo) =>
        {$color, video, videoUrl} = visibilityInfo.data

        $color.css
          display: 'block'

        if video and videoUrl
          @videoManager.play video, videoUrl,
            restart: true

      hidden: (visibilityInfo) =>
        {$color, video} = visibilityInfo.data

        $color.css
          display: 'none'

        @videoManager.pause video if video

      destroyed: (visibilityInfo) =>
        video = visibilityInfo.data.video
        @videoManager.end video if video

    @profileVisibilityTracker.start()

    # Update profile visibility on resizes and profile updates.
    @autorun (computation) =>
      AM.Window.clientBounds()
      profiles = @profiles()

      # Also update measurements when retiring a submission changes an artist's background.
      @_backgroundForProfile profile for profile in profiles or []

      # Wait until the new profile elements get rendered.
      Tracker.afterFlush =>
        return unless @isRendered()

        @profileVisibilityTracker.refresh()

  onDestroyed: ->
    super arguments...

    @profileVisibilityTracker?.destroy()
    @videoManager.destroy()

  year: ->
    parseInt AB.Router.getParameter 'year'

  favoritesButtonDisabledAttribute: ->
    disabled: true if @sortingParameter() is @constructor.SortingParameters.FavoritesCount

  submissionsButtonDisabledAttribute: ->
    disabled: true if @sortingParameter() is @constructor.SortingParameters.SubmissionsCount

  followersButtonDisabledAttribute: ->
    disabled: true if @sortingParameter() is @constructor.SortingParameters.FollowersCount

  statistics: ->
    profile = @currentData()

    profile.pixelDailies.statisticsByYear[@year()]

  background: ->
    @_backgroundForProfile @currentData()

  _backgroundForProfile: (profile) ->
    submission = PADB.PixelDailies.Submission.documents.findOne
      'user.screenName': new RegExp profile.username, 'i'
      processingError: PADB.PixelDailies.Pages.YearReview.Helpers.displayableSubmissionsCondition
    ,
      sort:
        favoritesCount: -1

    submission?.images[0]

  loading: ->
    not @subscriptionsReady()

  events: ->
    super(arguments...).concat
      'click .favorites.view-mode-button': @onClickFavoritesViewModeButton
      'click .submissions.view-mode-button': @onClickSubmissionsViewModeButton
      'click .followers.view-mode-button': @onClickFollowersViewModeButton

  onClickFavoritesViewModeButton: (event) ->
    @sortingParameter @constructor.SortingParameters.FavoritesCount

  onClickSubmissionsViewModeButton: (event) ->
    @sortingParameter @constructor.SortingParameters.SubmissionsCount

  onClickFollowersViewModeButton: (event) ->
    @sortingParameter @constructor.SortingParameters.FollowersCount
