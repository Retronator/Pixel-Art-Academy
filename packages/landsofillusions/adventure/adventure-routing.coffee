AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  currentUrl: ->
    AB.Router.currentRoutePath()

  @_directRouteHandlersByUrl = {}
  @_directRouteHandlersByWildcardUrl = {}

  # Registers a handler to be called when accessing the provided URL.
  @registerDirectRoute: (url, handler) ->
    # See if we have a wildcard URL.
    if match = url.match /(.*)\/\*$/
      url = match[1]
      @_directRouteHandlersByWildcardUrl[url] = handler

    else
      @_directRouteHandlersByUrl[url] = handler

  @getDirectRouteHandlerForUrl: (url) ->
    handler = @_directRouteHandlersByUrl[url]
    return handler if handler

    # Try wildcard urls as well.
    for handlerUrl, handler of @_directRouteHandlersByWildcardUrl
      if url.indexOf(handlerUrl) is 0
        return handler

  _initializeRouting: ->
    # Route to dialog or thing that has direct access by URL.
    @autorun (computation) =>
      url = @currentUrl()

      console.log "%cURL has changed to", 'background: PapayaWhip', url if LOI.debug

      # We only want to react to router changes.
      Tracker.nonreactive =>
        # Find if this is an item or location.
        handler = @constructor.getDirectRouteHandlerForUrl url

        console.log "Found a custom handler for this route." if handler and LOI.debug

        # If we got a handler, let it deal with the URL (get the game into the state it needs to be).
        handler?()

    # Rewrite url to match the top-most dialog, active item or current location.
    @autorun (computation) =>
      # Find the first dialog in the stack that has a url.
      for dialogOptions in @modalDialogs()
        dialog = dialogOptions.dialog
        
        # See if the instance or constructor can provide the url.
        if dialog.url or dialog.constructor.url
          desiredUrl = dialog.url?()
          desiredUrl ?= dialog.constructor.url()
          break

      unless desiredUrl?
        # We don't have any URLs in the dialogs, next try active item (first) and location (second).
        activeItemId = @activeItemId()
        activeItem = @activeItem()

        # Wait until desired active item is instantiated.
        return if activeItemId and activeItemId isnt activeItem?.id()

        currentLocation = @currentLocation()

        thing = activeItem or currentLocation
        desiredUrl = thing?.url?()
        desiredUrl ?= thing?.constructor.url()

      return unless desiredUrl?

      currentUrl = @currentUrl()

      if _.endsWith desiredUrl, '/*'
        urlPrefix = desiredUrl.substring 0, desiredUrl.length - 2
        return if currentUrl.indexOf urlPrefix is 0

      else
        return if desiredUrl is currentUrl

      console.log "%cRewriting URL to", 'background: NavajoWhite', desiredUrl if LOI.debug

      parametersObject = @buildDesiredUrlParameters desiredUrl

      AB.Router.goToRoute @constructor.id(), parametersObject, createHistory: false

  buildDesiredUrlParameters: (url) ->
    # Override to provide different URL parameters.
    parametersObject = {}

    if url.length
      urlParameters = url.split '/'

      for urlParameter, index in urlParameters
        parametersObject["parameter#{index + 1}"] = urlParameter unless urlParameter is '*'

    parametersObject

  goToItem: (itemClassOrId) ->
    @activeItemId _.thingId itemClassOrId
