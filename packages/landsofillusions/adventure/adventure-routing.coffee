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
    # Match url to the active item or current location.
    @autorun =>
      activeItemId = @activeItemId()
      currentLocationId = @currentLocationId()

      thingClass = LOI.Adventure.Thing.getClassForId activeItemId or currentLocationId
      return unless thingClass
      
      desiredUrl = thingClass.url()
      currentUrl = @currentUrl()

      if _.endsWith desiredUrl, '/*'
        urlPrefix = desiredUrl.substring 0, desiredUrl.length - 2
        return if currentUrl.indexOf urlPrefix is 0

      else
        return if desiredUrl is currentUrl

      console.log "%cRewriting URL for item", 'background: NavajoWhite', activeItemId, "or location", currentLocationId if LOI.debug

      FlowRouter.go 'LandsOfIllusions.Adventure', thingClass.urlParameters()

  goToLocation: (locationClassOrId) ->
    @currentLocationId _.thingId locationClassOrId

  goToItem: (itemClassOrId) ->
    @activeItemId _.thingId itemClassOrId
