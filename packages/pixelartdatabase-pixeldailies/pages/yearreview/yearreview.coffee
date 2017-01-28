AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview'

  @themeProvidersByYears = {}

  constructor: ->
    super

    @currentBackgroundIndex = new ReactiveField null
    @yearCalendarProvider = new ReactiveField null
    @isValidYear = new ReactiveField false

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

      @isValidYear true

      @backgrounds = _.cloneDeep @yearClass.backgrounds

      # Shuffle the backgrounds, but leave the starting one fixed.
      @backgrounds = _.flatten [@backgrounds[0], _.shuffle @backgrounds[1..]]

      # Create a persistent calendar provider so we don't have to re-fetch themes between page changes. We need to
      # subscribe in a non-rective context, so that the subscription doesn't get invalidated when this component is
      # destroyed.
      Tracker.nonreactive =>
        @constructor.themeProvidersByYears[year] ?= new @constructor.ThemesCalendarProvider year: year
        @yearCalendarProvider @constructor.themeProvidersByYears[year]

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

  allMonthsDisplayed: ->
    calendar = @childComponents(@constructor.Components.Calendar)[0]
    return unless calendar

    # All months are displayed if the last month is december
    _.last(calendar.months())?.number is 11

  insertDOMElement: (parent, node, before) ->
    super
    $node = $(node)

    return unless $node.hasClass 'background'

    # Do a background transition.
    position = @backgrounds[@currentBackgroundIndex()].position

    $node.css(backgroundPositionY: position[0])

    transitionDelay = if @_firstTransitionDone then 500 else 2000
    @_firstTransitionDone = true

    Meteor.setTimeout =>
      $node.addClass('transition').css(backgroundPositionY: position[1])
    ,
      transitionDelay

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
