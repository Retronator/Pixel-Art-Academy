AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Browser extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Browser'

  constructor: (@computer) ->
    super

  onCreated: ->
    super

    @currentRoute = new ReactiveField null

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

  url: -> @history()[@historyIndex()].url

  setUrl: (url) ->
    # Make sure the url actually changed.
    return if url is @url()

    @_updateCurrentScrollTop()

    historyIndex = @historyIndex()
    history = @history()

    # First shorten history to current index.
    history = history.slice 0, historyIndex + 1
    history.push {url}
    historyIndex++

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

    # We want to blacklist Adventure routes.
    route = null if route?.pageClass is LOI.Adventure or route?.pageClass.prototype instanceof LOI.Adventure

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
    super.concat
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
