AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Browser extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Browser'

  constructor: (@computer) ->
    super arguments...

  onCreated: ->
    super arguments...

    @currentRoute = new ReactiveField null, (a, b) => a is b

    @history = new ReactiveField [{url: 'https://retropolis.city/academy-of-art', scrollTop: 0}]
    @historyIndex = new ReactiveField 0

    @autorun (computation) =>
      return unless url = @url()

      match = url.match /^https?:\/\//
      unless match
        # We need to add the protocol.
        @setUrl "https://#{url}"
        return

      route = @routeFromUrl url
      @currentRoute route

  url: (url, options) ->
    # Allow setting the url by sending in the new value.
    return @setUrl url if url?

    @history()[@historyIndex()].url

  setUrl: (url, options = {}) ->
    # Make sure the url actually changed.
    return if url is @url()

    # By default changing the URL gets written to browser history.
    options.createHistory ?= true

    history = @history()
    historyIndex = @historyIndex()

    if options.createHistory
      # Store the scroll position before we move on.
      @_updateCurrentScrollTop()

      # Shorten history to current index (cutting away any pages after current).
      history = history.slice 0, historyIndex + 1

      # Add new url.
      history.push {url}
      historyIndex++

    else
      # Replace the url of the current history item.
      history.url = url

    @history history
    @historyIndex historyIndex

  _updateCurrentScrollTop: ->
    @history()[@historyIndex()].scrollTop = @$('.webpage').scrollTop()

  appId: -> 'browser'
  name: -> 'Web Surfer'

  backButtonCallback: ->
    @computer.switchToScreen @computer.screens.desktop

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  routeFromUrl: (url) ->
    # Determine if we can serve the webpage ourselves. Also make sure this is a valid url.
    link = $("<a href='#{url}'>")[0]

    host = link.hostname
    path = link.pathname

    {route, matchData} = AB.Router.findRoute host, path

    # We want to blacklist some pages.
    blacklistedPages = [
      LOI.Adventure
    ]

    for page in blacklistedPages
      route = null if route?.pageClass is page or route?.pageClass.prototype instanceof page

    route

  renderWebpage: ->
    return null unless currentRoute = @currentRoute()

    # We instantiate the page so that we can send the instance to the Render component. If it was just a class, it
    # would treat it as a function and try to execute it instead of pass it as the context to the Render component.
    layoutData =
      page: new currentRoute.pageClass

    # Update scroll top after the route is rendered.
    Tracker.afterFlush =>
      @$('.webpage')?.scrollTop(@history()[@historyIndex()].scrollTop or 0)

    new Blaze.Template =>
      Blaze.With layoutData, =>
        currentRoute.layoutClass.renderComponent @

  previousPageDisabledAttribute: ->
    'disabled' if @historyIndex() is 0

  nextPageDisabledAttribute: ->
    'disabled' if @historyIndex() is @history().length - 1

  events: ->
    super(arguments...).concat
      'click .close-button': @onClickCloseButton
      'change .url-input': @onChangeUrlInput
      'click a': @onClickAnchor
      'click .previous-page-button': @onClickPreviousPageButton
      'click .next-page-button': @onClickNextPageButton

  onClickCloseButton: (event) ->
    @computer.switchToScreen @computer.screens.desktop

  onChangeUrlInput: (event) ->
    url = $(event.target).val()
    @setUrl url

  onClickAnchor: (event) ->
    # Do not react if modifier keys are present (the user might be trying to open the link in a new tab).
    return if event.metaKey or event.ctrlKey or event.shiftKey

    # Do not redirect away from the current page.
    event.preventDefault()

    link = event.currentTarget
    href = $(link).attr('href')

    [match, origin, pathname] = href.match /^(.*?)(\/.*)?$/

    pathname ?= "/"

    # Fill the origin from the current url.
    unless origin
      location = $("<a href='#{@url()}'>")[0]
      origin = location.origin

    url = "#{origin}#{pathname}"

    # Make sure we can serve the url.
    route = @routeFromUrl url

    unless route
      # Open the link in a new tab.
      window.open url, '_blank'
      return

    @setUrl url

  onClickPreviousPageButton: (event) ->
    @_updateCurrentScrollTop()
    newIndex = Math.max 0, @historyIndex() - 1
    @historyIndex newIndex

  onClickNextPageButton: (event) ->
    @_updateCurrentScrollTop()
    maxIndex = @history().length
    newIndex = Math.min maxIndex, @historyIndex() + 1
    @historyIndex newIndex
