AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview.Artist extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview.Artist'

  # Subscriptions
  
  @mostPopular: new AB.Subscription
    name: "#{@componentName()}.mostPopular"
    query: (screenName, year, limit) =>
      # Take top submissions in the year.
      yearRange = new AE.DateRange year: year

      submissionsQuery =
        'user.screenName': new RegExp screenName, 'i'
        processingError:
          $ne: PADB.PixelDailies.Submission.ProcessingError.NoImages

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

    @streamView = new ReactiveField false

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
      [submissionsCursor, artworksCursor] = @constructor.mostPopular.query @screenName(), @year(), @topArtworksLimit()

      PADB.PixelDailies.Pages.YearReview.Helpers.prepareTopArtworks artworksCursor.fetch()

  onRendered: ->
    super

    @_changeBackgroundInterval = Meteor.setInterval =>
      artworksCount = @topArtworks()?.length or 1
      newIndex = (@currentBackgroundIndex() + 1) % artworksCount

      # Temporarily remove the background so that animations get triggered.
      @currentBackgroundIndex null

      Tracker.afterFlush =>
        @currentBackgroundIndex newIndex
    ,
      10000

    @currentBackgroundIndex 0

    @autorun (computation) =>
      if @streamView()
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
    PADB.Profile.documents.findOne
      username: new RegExp @screenName(), 'i'

  background: ->
    index = @currentBackgroundIndex()
    return unless index?

    artwork = @topArtworks()[index]
    return unless artwork

    url: artwork.firstImageRepresentation().url

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
      'click .fullscreen': @onClickFullscreen

  onClickFullscreen: (event) ->
    AM.Window.enterFullscreen()
