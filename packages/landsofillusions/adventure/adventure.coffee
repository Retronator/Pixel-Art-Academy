AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  ready: ->
    console.log "Am I ready? Parser:", @parser.ready(), "Current location:", @currentLocation()?.ready()
    @parser.ready() and @currentLocation()?.ready()

  initializeGameState: (state) ->
    inventory = {}
    inventory[Retronator.HQ.Items.Wallet.id()] = {}

    locations = {}
    locations[Retronator.HQ.Locations.Elevator.id()] =
      floor: 1

    _.extend state,
      player:
        inventory: inventory
      locations: locations
      initialized: true

    console.log "INITIALIZED STATE", state

  logout: ->
    # Notify game state that it should flush any cached updates.
    @gameState?.updated flush: true

    # Log out the user.
    Meteor.logout()

  showDescription: (thing) ->
    @interface.showDescription thing

  @goToLocation: (locationClassOrId) ->
    locationId = if _.isFunction locationClassOrId then locationClassOrId.id() else locationClassOrId
    console.log "%cRouting to location with ID", 'background: NavajoWhite', locationId if LOI.debug

    locationClass = LOI.Adventure.Location.getClassForID locationId
    FlowRouter.go 'LandsOfIllusions.Adventure', locationClass.urlParameters()

  @goToItem: (itemClassOrId) ->
    itemId = if _.isFunction itemClassOrId then itemClassOrId.id() else itemClassOrId
    console.log "%cRouting to item with ID", 'background: NavajoWhite', itemId if LOI.debug

    itemClass = LOI.Adventure.Item.getClassForID itemId
    FlowRouter.go 'LandsOfIllusions.Adventure', itemClass.urlParameters()

  # Rewrites the URL to match the current item or location we're at.
  rewriteUrl: ->
    activeItemId = @activeItemId()

    console.log "%cRerouting to URL for item", 'background: NavajoWhite', activeItemId, "or location", @currentLocationId() if LOI.debug

    if activeItemId
      LOI.Adventure.goToItem activeItemId

    else
      LOI.Adventure.goToLocation @currentLocationId()

  deactivateCurrentItem: ->
    # We simply go back to the URL of the current location since that will deactivate the currently active item.
    @constructor.goToLocation @currentLocation().id()
