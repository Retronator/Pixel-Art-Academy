AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview'

  @themeProvidersByYears = {}

  constructor: ->
    super

    @currentBackgroundIndex = new ReactiveField null

  onCreated: ->
    super

    # React to year changes.
    @autorun (computation) =>
      year = @year()
      @yearClass = @constructor.Years[year]

      # See if this is a valid year.
      unless @yearClass
        FlowRouter.go 'PixelArtDatabase.PixelDailies.Pages.Home'
        return

      @isValidYear = true

      @backgrounds = _.cloneDeep @yearClass.backgrounds

      # Shuffle the backgrounds, but leave the starting one fixed.
      @backgrounds = _.flatten [@backgrounds[0], _.shuffle @backgrounds[1..]]

      # Create a persistent calendar provider so we don't have to re-fetch themes between page changes. We need to
      # subscribe in a non-rective context, so that the subscription doesn't get invalidated when this component is
      # destroyed.
      Tracker.nonreactive =>
        @constructor.themeProvidersByYears[year] ?= new @constructor.ThemesCalendarProvider year: year
        @yearCalendarProvider = @constructor.themeProvidersByYears[year]

  onRendered: ->
    super

    @_changeBackgroundInterval = Meteor.setInterval =>
      newIndex = (@currentBackgroundIndex() + 1) % @backgrounds.length

      # Temporarily remove the background so that animations get triggered.
      @currentBackgroundIndex null

      Tracker.afterFlush =>
        @currentBackgroundIndex newIndex
    ,
      10000

    @currentBackgroundIndex 0

    calendar = @childComponents(@constructor.Components.Calendar)[0]

    # Raise limit to the number of currently loaded themes.
    currentLimit = calendar.infiniteScroll.limit()
    newLimit = Math.max currentLimit, @yearCalendarProvider.limit()

    calendar.infiniteScroll.limit newLimit

  onDestroyed: ->
    Meteor.clearInterval @_changeBackgroundInterval

  year: ->
    parseInt FlowRouter.getParam 'year'

  isCurrentYear: ->
    currentYear = new Date().getFullYear()
    @year() is currentYear

  background: ->
    index = @currentBackgroundIndex()
    return unless index?

    @backgrounds[index]

  authorUrl: ->
    background = @currentData()

    FlowRouter.path 'PixelArtDatabase.PixelDailies.Pages.YearReview.Artist',
      year: FlowRouter.getParam 'year'
      screenName: _.toLower background.author

  insertDOMElement: (parent, node, before) ->
    super
    $node = $(node)

    return unless $node.hasClass 'background'

    # Do a background transition.
    position = @backgrounds[@currentBackgroundIndex()].position

    $node.css(backgroundPositionY: position[0])

    Meteor.setTimeout =>
      $node.addClass('transition').css(backgroundPositionY: position[1])
    ,
      500

  removeDOMElement: (parent, node) ->
    $node = $(node)

    unless $node.hasClass 'background'
      super
      return

    $node.addClass('old').velocity
      opacity: [0, 1]
    ,
      duration: 1000
      complete: => $node.remove()
