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

  _initializeRouting: ->
    @autorun =>
      url = @currentUrl()

      console.log "%cURL has changed to", 'background: PapayaWhip', url if LOI.debug

      # We only want to react to router changes.
      Tracker.nonreactive =>
        # Find if this is an item or location.
        constructor = LOI.Adventure.Thing.getClassForUrl url

        # Make sure we're on the right subdomain.
        constructor = null if constructor?.welcomeHostname and location.hostname isnt Meteor.settings.public.welcomeHostname
        constructor = null if not constructor?.welcomeHostname and location.hostname is Meteor.settings.public.welcomeHostname

        console.log "Thing class for this URL is", constructor if LOI.debug

        unless constructor
          # We didn't find a thing for this URL. Just go to whatever location/item is set in the state.
          @rewriteUrl()
          return

        if constructor.prototype instanceof LOI.Adventure.Location
          # We are at a location. Deactivate an item if there was one activated via URL.
          @activeItemId null

          if constructor isnt @currentLocation()?.constructor
            # We are at a location. Switch to it.
            @currentLocationId constructor.id()

        else if constructor.prototype instanceof LOI.Adventure.Item
          @activeItemId constructor.id()

  # Rewrites the URL to match the current item or location we're at.
  rewriteUrl: ->
    activeItemId = @activeItemId()
    currentLocationId = @currentLocationId()

    thingClass = LOI.Adventure.Thing.getClassForId activeItemId or currentLocationId
    desiredUrl = thingClass.url()
    currentUrl = @currentUrl()

    if _.endsWith desiredUrl, '/*'
      urlPrefix = desiredUrl.substring 0, desiredUrl.length - 2
      return if currentUrl.indexOf urlPrefix is 0
      
    else
      return if desiredUrl is currentUrl

    console.log "%cRerouting to URL for item", 'background: NavajoWhite', activeItemId, "or location", currentLocationId if LOI.debug

    if activeItemId
      LOI.Adventure.goToItem activeItemId

    else
      LOI.Adventure.goToLocation currentLocationId

  @goToLocation: (locationClassOrId) ->
    locationClass = if _.isFunction locationClassOrId then locationClassOrId else LOI.Adventure.Location.getClassForId locationClassOrId     
    console.log "%cRouting to location with ID", 'background: NavajoWhite', locationClass.id() if LOI.debug

    FlowRouter.go 'LandsOfIllusions.Adventure', locationClass.urlParameters()

  @goToItem: (itemClassOrId) ->
    itemClass = if _.isFunction itemClassOrId then itemClassOrId else LOI.Adventure.Item.getClassForId itemClassOrId
    console.log "%cRouting to item with ID", 'background: NavajoWhite', itemClass.id() if LOI.debug

    FlowRouter.go 'LandsOfIllusions.Adventure', itemClass.urlParameters()
