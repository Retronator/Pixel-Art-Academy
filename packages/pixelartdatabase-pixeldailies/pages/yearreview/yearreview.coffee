AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.YearReview extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.YearReview'
  
  constructor: ->
    super

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

    @currentBackgroundIndex = new ReactiveField null

    @yearCalendarProvider = new @constructor.ThemesCalendarProvider year: year

    @calendar = new ReactiveField null

  onCreated: ->
    super

    @autorun (computation) =>
      return unless calendar = @calendar()
      
      # Update how many items the provider should return.
      @yearCalendarProvider.limit calendar.infiniteScroll.limit()

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

    @calendar @childComponents(@constructor.Components.Calendar)[0]

  onDestroyed: ->
    Meteor.clearInterval @_changeBackgroundInterval

    @yearCalendarProvider.destroy()

  year: ->
    parseInt FlowRouter.getParam 'year'

  isCurrentYear: ->
    currentYear = new Date().getFullYear()
    @year() is currentYear

  background: ->
    index = @currentBackgroundIndex()
    return unless index?

    @backgrounds[index]

  isFullscreen: ->
    AM.Window.isFullscreen()

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

  events: ->
    super.concat
      'click .fullscreen': @onClickFullscreen

  onClickFullscreen: (event) ->
    AM.Window.enterFullscreen()
