AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  currentUrl: ->
    parameters = [
      FlowRouter.getParam 'parameter1'
      FlowRouter.getParam 'parameter2'
      FlowRouter.getParam 'parameter3'
      FlowRouter.getParam 'parameter4'
    ]

    # Remove unused parameters.
    parameters = _.without parameters, undefined

    # Create a path from parameters.
    parameters.join '/'

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

        console.log "Found a custom handler for this route." if LOI.debug and handler

        # If we got a handler, let it deal with the URL (get the game into the state it needs to be).
        handler?()

    # Rewrite url to match the top-most dialog, active item or current location.
    @autorun (computation) =>
      # Find the first dialog in the stack that has a url.
      for dialog in _.reverse @modalDialogs()
        # See if the instance or constructor can provide the url.
        if dialog.url or dialog.constructor.url
          desiredUrl = dialog.url?()
          desiredUrl ?= dialog.constructor.url()
          break

      unless desiredUrl?
        # We don't have any URLs in the dialogs, next try active item (first) and location (second).
        activeItemId = @activeItemId()
        currentLocationId = @currentLocationId()

        thingClass = LOI.Adventure.Thing.getClassForId activeItemId or currentLocationId
        desiredUrl = thingClass?.url()

      return unless desiredUrl?

      currentUrl = @currentUrl()

      if _.endsWith desiredUrl, '/*'
        urlPrefix = desiredUrl.substring 0, desiredUrl.length - 2
        return if currentUrl.indexOf urlPrefix is 0

      else
        return if desiredUrl is currentUrl

      console.log "%cRewriting URL to", 'background: NavajoWhite', desiredUrl if LOI.debug

      urlParameters = desiredUrl.split '/'
      parametersObject = {}

      for urlParameter, i in urlParameters
        parametersObject["parameter#{i + 1}"] = urlParameter unless urlParameter is '*'

      FlowRouter.go 'LandsOfIllusions.Adventure', parametersObject

  goToLocation: (locationClassOrId) ->
    @currentLocationId _.thingId locationClassOrId

  goToItem: (itemClassOrId) ->
    @activeItemId _.thingId itemClassOrId
