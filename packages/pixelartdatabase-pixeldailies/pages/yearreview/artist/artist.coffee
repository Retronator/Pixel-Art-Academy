AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Artist extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Artist'

  @title: (options) ->
    profile = @profile options.screenName
    return unless profile
    
    "Retronator // Top Pixel Dailies #{options.year}: #{profile.displayName} (@#{profile.username})"
      
  @description: (options) ->
    profile = @profile options.screenName

    "The best Pixel Dailies submissions from #{profile.displayName} in #{options.year}."

  @image: (options) ->
    # Find the best submission for this artist.
    [submissionsCursor, artworksCursor] = @mostPopular.query options.screenName, options.year, 1
    submissionsCursor.fetch()[0].images[0].imageUrl

  @profile: (screenName) ->
    PADB.Profile.documents.findOne
      username: new RegExp screenName, 'i'
    
  # Subscriptions
  
  @mostPopular: new AB.Subscription
    name: "#{@componentName()}.mostPopular"
    query: (screenName, year, limit) =>
      # Take top submissions in the year.
      yearRange = new AE.DateRange year: year

      submissionsQuery =
        'user.screenName': new RegExp screenName, 'i'
        processingError: PADB.PixelDailies.Pages.YearReview.Helpers.displayableSubmissionsCondition

      yearRange.addToMongoQuery submissionsQuery, 'time'

      submissionsCursor = PADB.PixelDailies.Submission.documents.find submissionsQuery,
        sort:
          favoritesCount: -1
        limit: limit
        fields:
          tweetData: 0

      artworksCursor = PADB.PixelDailies.Pages.YearReview.Helpers.prepareArtworksCursorForSubmissionsCursor submissionsCursor

      [submissionsCursor, artworksCursor]

  constructor: ->
    super

    @currentBackgroundIndex = new ReactiveField null

    @yearCalendarProvider = new ReactiveField null

    @stream = new ReactiveField null

    @streamViewActive = new ReactiveField false

    @displayedSubmission = new ReactiveField null

  onCreated: ->
    super

    # React to year and screen name changes.
    @autorun (computation) =>
      year = @year()
      screenName = @screenName()
      return unless year and screenName

      PADB.Profile.forUsername.subscribe @, screenName

      @yearCalendarProvider new @constructor.CalendarProvider
        screenName: screenName
        year: year

    # We always want at least 10 top artworks, since we use them in the user banner, not just the stream.
    @topArtworksLimit = new ComputedField =>
      streamLimit = @stream()?.infiniteScroll.limit() or 0
      Math.max 10, streamLimit

    @autorun (computation) =>
      @constructor.mostPopular.subscribe @, @screenName(), @year(), @topArtworksLimit()

    # Prepare top user's artworks.
    @topArtworks = new ComputedField =>
      # Wait for most popular subscription to kick in.
      return unless @subscriptionsReady()

      [submissionsCursor, artworksCursor] = @constructor.mostPopular.query @screenName(), @year(), @topArtworksLimit()

      PADB.PixelDailies.Pages.YearReview.Helpers.prepareTopArtworks artworksCursor.fetch()

    # Convert displayed submission to artworks, so we can show them in a stream.
    @displayedArtworks = new ComputedField =>
      return unless submission = @displayedSubmission()

      PADB.PixelDailies.Pages.YearReview.Helpers.convertSubmissionToArtworks submission

  onRendered: ->
    super

    @_changeBackgroundInterval = Meteor.setInterval =>
      # Choose between one of the first 10 artworks that are always subscribed (but could be less than 10 total).
      artworksCount = @topArtworks()?.length or 1
      bannerArtworksCount = Math.min 10, artworksCount
      newIndex = (@currentBackgroundIndex() + 1) % bannerArtworksCount

      # Temporarily remove the background so that animations get triggered.
      @currentBackgroundIndex null

      Tracker.afterFlush =>
        @currentBackgroundIndex newIndex
    ,
      10000

    @currentBackgroundIndex 0

    @autorun (computation) =>
      if @streamViewActive()
        Tracker.afterFlush =>
          @stream @childComponents(PixelArtDatabase.PixelDailies.Pages.YearReview.Components.Stream)[0]

      else
        @stream null

  onDestroyed: ->
    Meteor.clearInterval @_changeBackgroundInterval

  year: ->
    parseInt FlowRouter.getParam 'year'

  screenName: ->
    FlowRouter.getParam 'screenName'

  profile: ->
    @constructor.profile @screenName()

  statistics: ->
    @profile().pixelDailies.statisticsByYear[@year()] or
      favoritesCount: 0
      submissionsCount: 0

  background: ->
    index = @currentBackgroundIndex()
    return unless index?

    artwork = @topArtworks()?[index]
    return unless artwork

    url: artwork.firstImageRepresentation().url

  calendarButtonDisabledAttribute: ->
    disabled: true unless @streamViewActive()

  streamButtonDisabledAttribute: ->
    disabled: true if @streamViewActive()

  insertDOMElement: (parent, node, before) ->
    super
    $node = $(node)

    return #unless $node.hasClass 'background'

    # Do a background transition.
    $keyImage = $node.find('.key-image')
    $keyImage.css(backgroundPositionY: @_randomBackgroundPositionY())

    Meteor.setTimeout =>
      $keyImage.addClass('transition').css(backgroundPositionY: @_randomBackgroundPositionY())
    ,
      500

  _randomBackgroundPositionY: ->
    position = 25 + Math.random() * 50
    "#{position}%"

  removeDOMElement: (parent, node) ->
    $node = $(node)

    unless $node.hasClass 'background'
      super
      return

    $node.addClass('old')

    Meteor.setTimeout =>
      $node.addClass('transition').css(opacity: 0)

      Meteor.setTimeout =>
        $node.remove()
      ,
        1500

  events: ->
    super.concat
      'click .calendar.view-mode-button': @onClickCalendarViewModeButton
      'click .stream.view-mode-button': @onClickStreamViewModeButton
      'click .day': @onClickDay
      'click .displayed-artworks': @onClickDisplayedArtworks

  onClickCalendarViewModeButton: (event) ->
    @streamViewActive false

  onClickStreamViewModeButton: (event) ->
    @streamViewActive true
    
  onClickDay: (event) ->
    day = @currentData()
    @displayedSubmission day.submission

  onClickDisplayedArtworks: (event) ->
    # Close displayed artworks.
    @displayedSubmission null
