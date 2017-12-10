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

    @_profilesVisibilityData = []

  onRendered: ->
    super
    @_$window = $(window)

    @_$window.on 'scroll.pixelartdatabase-pixeldailies-pages-yearreview-artists', (event) => @onScroll()

    # Update active profiles on resizes and profile updates.
    @autorun (computation) =>
      AM.Window.clientBounds()
      @profiles()

      # Wait till the new artwork areas get rendered.
      Tracker.afterFlush =>
        # Everything is deactivated when first rendered so make sure visibility data reflects that.
        visibilityData.active = false for visibilityData in @_profilesVisibilityData

        @_measureProfiles()
        @_updateProfilesVisibility()

  onDestroyed: ->
    super

    @_$window.off '.pixelartdatabase-pixeldailies-pages-yearreview-artists'

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
    profile = @currentData()

    submission = PADB.PixelDailies.Submission.documents.findOne
      'user.screenName': new RegExp profile.username, 'i'
      processingError: PADB.PixelDailies.Pages.YearReview.Helpers.displayableSubmissionsCondition
    ,
      sort:
        favoritesCount: -1

    submission?.images[0]

  onScroll: ->
    # Update visibility every 0.2s when scrolling.
    @_throttledUpdateProfilesVisibility ?= _.throttle =>
      @_updateProfilesVisibility()
    ,
      200

    @_throttledUpdateProfilesVisibility()

  _measureProfiles: ->
    # Get top and bottom positions of all artworks.
    $profiles = @$('.profile')
    return unless $profiles

    for profileElement, index in $profiles
      $profile = $(profileElement)
      top = $profile.offset().top
      bottom = top + $profile.height()

      @_profilesVisibilityData[index] ?= {}
      @_profilesVisibilityData[index].element = profileElement
      @_profilesVisibilityData[index].$profile = $profile
      @_profilesVisibilityData[index].$color = $profile.find('.color')
      @_profilesVisibilityData[index].top = top
      @_profilesVisibilityData[index].bottom = bottom

  _updateProfilesVisibility: ->
    viewportTop = @_$window.scrollTop()
    windowHeight = @_$window.height()
    viewportBottom = viewportTop + windowHeight

    # Expand one extra screen beyond the viewport
    visibilityEdgeTop = viewportTop - windowHeight
    visibilityEdgeBottom = viewportBottom + windowHeight

    # Go over all the profiles and activate the one at the new index.
    for visibilityData, index in @_profilesVisibilityData
      # Profile is visible if it is anywhere in between the visibility edges.
      profileShouldBeActive = visibilityData.bottom > visibilityEdgeTop and visibilityData.top < visibilityEdgeBottom

      # Activate or deactivate profiles. Note that active is undefined at the start.
      if profileShouldBeActive and visibilityData.active isnt true
        # We must activate this profile.
        $profile = visibilityData.$profile

        visibilityData.$color.css
          display: 'block'

        for video in $profile.find('video')
          video.currentTime = 0
          video.play()

        visibilityData.active = true

      else if not profileShouldBeActive and visibilityData.active isnt false
        # We need to deactivate this profile.
        $profile = visibilityData.$profile

        visibilityData.$color.css
          display: 'none'

        for video in $profile.find('video')
          video.pause()

        visibilityData.active = false

  loading: ->
    not @subscriptionsReady()

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
