AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  @register 'LandsOfIllusions.Adventure'

  constructor: ->
    super

  onCreated: ->
    super

    @currentLocation = new ReactiveField null

    @inventory = new LOI.Adventure.Inventory adventure: @
    @activeItem = new ReactiveField null

    @interface = new LOI.Adventure.Interface.Text adventure: @
    @parser = new LOI.Adventure.Parser adventure: @

    @state = new ReactiveField null
    Artificial.Mummification.PersistentStorage.persist
      storageKey: "LandsOfIllusions.Adventure.state"
      field: @state
      tracker: @

    if @state()
      # We loaded the state from local storage.

    else
      # It's our first time at Pixel Art Academy.

      # Start in the lobby location.
      lobby = new Retronator.HQ.Locations.Lobby adventure: @
      @currentLocation lobby

      # Start with a wallet in the inventory.
      @inventory.addItem new Retronator.HQ.Items.Wallet adventure: @

  onRendered: ->
    super

    # Handle url changes.
    @autorun =>
      # Let's see what our url path is like. We do it with getParams instead
      # of directly from location pathname to depend reactively on it.
      parameters = [
        FlowRouter.getParam 'parameter1'
        FlowRouter.getParam 'parameter2'
        FlowRouter.getParam 'parameter3'
        FlowRouter.getParam 'parameter4'
      ]

      # Remove unused parameters.
      parameters = _.without parameters, undefined

      # Create a path from parameters.
      url = parameters.join '/'

      # We only want to react to router changes.
      Tracker.nonreactive =>
        # Find if this is an item or location.
        locationClass = LOI.Adventure.Location.getClassForUrl url
        itemClass = LOI.Adventure.Item.getClassForUrl url

        if locationClass
          # Deactivate an item that was activated via URL.
          activeItem = @activeItem()
          activeItem?.deactivate()
          @activeItem null

          if locationClass isnt @currentLocation()?.constructor
            # We are at a location. Destroy the previous location and create the new one.
            @currentLocation()?.destroy()
            location = new locationClass
              adventure: @

            # Switch to new location.
            @currentLocation location

        if itemClass
          # We are trying to use this item.
          item = @inventory[itemClass.id()]

          if item
            # Good, we have this item in the inventory. Activate it.
            item.activate()
            @activeItem item

          else
            # We can't use an item we don't have. Return the URL to the location.
            @constructor.goToLocation @currentLocation().id()

  onDestroyed: ->
    super

    $('html').removeClass('lands-of-illusions-style-adventure')

  ready: ->
    @parser.ready() and @currentLocation()?.ready()

  @goToLocation: (locationClassOrId) ->
    locationId = if _.isFunction locationClassOrId then locationClassOrId.id() else locationClassOrId
    locationClass = LOI.Adventure.Location.getClassForID locationId
    FlowRouter.go 'LandsOfIllusions.Adventure', locationClass.urlParameters()

  @activateItem: (itemClassOrId) ->
    itemId = if _.isFunction itemClassOrId then itemClassOrId.id() else itemClassOrId
    itemClass = LOI.Adventure.Item.getClassForID itemId
    FlowRouter.go 'LandsOfIllusions.Adventure', itemClass.urlParameters()

  deactivateCurrentItem: ->
    # We simply go back to the URL of the current location since that will deactivate the currently active item.
    @constructor.goToLocation @currentLocation().id()
