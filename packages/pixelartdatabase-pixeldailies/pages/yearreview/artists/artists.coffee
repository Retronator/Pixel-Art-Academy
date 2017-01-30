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

  mixins: -> [@infiniteScroll]

  constructor: ->
    super

    @infiniteScroll = new PADB.PixelDailies.Pages.YearReview.Components.Mixins.InfiniteScroll step: 10
    @sortingParameter = new ReactiveField @constructor.SortingParameters.FavoritesCount

  onCreated: ->
    super

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

  year: ->
    parseInt FlowRouter.getParam 'year'

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
    profile = @currentData()

    submission = PADB.PixelDailies.Submission.documents.findOne
      'user.screenName': new RegExp profile.username, 'i'
      processingError: PADB.PixelDailies.Pages.YearReview.Helpers.displayableSubmissionsCondition
    ,
      sort:
        favoritesCount: -1

    submission?.images[0]

  events: ->
    super.concat
      'click .favorites.view-mode-button': @onClickFavoritesViewModeButton
      'click .submissions.view-mode-button': @onClickSubmissionsViewModeButton
      'click .followers.view-mode-button': @onClickFollowersViewModeButton

  onClickFavoritesViewModeButton: (event) ->
    @sortingParameter @constructor.SortingParameters.FavoritesCount

  onClickSubmissionsViewModeButton: (event) ->
    @sortingParameter @constructor.SortingParameters.SubmissionsCount

  onClickFollowersViewModeButton: (event) ->
    @sortingParameter @constructor.SortingParameters.FollowersCount
