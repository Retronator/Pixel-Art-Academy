AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  @register 'LandsOfIllusions.Adventure'

  constructor: ->
    super

  onCreated: ->
    super

    # Game state depends on whether the user is signed in or not and returns
    # the game  state from database when signed in or from local storage otherwise.
    @_localGameState = new LOI.LocalGameState

    @gameState = new ComputedField =>
      userId = Meteor.userId()

      if userId
        # Find the state from the database.
        gameState = LOI.GameState.documents.findOne('user._id': userId)
        return unless gameState

        state = gameState.state
        state.updated = => gameState.updated()

      else
        # Reactively get the state from local storage.
        state = @_localGameState.state()
        state.updated = => @_localGameState.updated()

      # Initialize state if needed.
      unless state.initialized
        # It's our first time playing Pixel Art Academy. Start with a wallet in the inventory.
        inventory = {}
        inventory[Retronator.HQ.Items.Wallet.id()] = {}

        _.extend state,
          player:
            inventory: inventory
          locations: {}
          initialized: true

        Tracker.nonreactive =>
          state.updated()

      state

    # We store player's current location locally so that multiple people
    # can use the same user account and walk around independently.
    @currentLocationId = new ReactiveField null
    Artificial.Mummification.PersistentStorage.persist
      storageKey: "LandsOfIllusions.Adventure.currentLocationId"
      field: @currentLocationId
      tracker: @

    # If we don't have a locally stored location, start in the lobby.
    unless @currentLocationId()
      @currentLocationId Retronator.HQ.Locations.Lobby.id()

    LOI.Adventure.goToLocation @currentLocationId()

    # Instantiate current location. It depends only on the ID.
    # HACK: ComputedField triggers recomputation when called from events so we use ReactiveField + autorun manually.
    @currentLocation = new ReactiveField null
    @autorun (computation) =>
      # React to location ID changes.
      currentLocationId = @currentLocationId()

      Tracker.nonreactive =>
        @_currentLocation?.destroy()

        currentLocationClass = LOI.Adventure.Location.getClassForID currentLocationId

        # Create a non-reactive reference so we can refer to it later.
        @_currentLocation = new currentLocationClass adventure: @

        # Reactively provide the state to the location.
        Tracker.autorun (computation) =>
          state = @gameState()?.locations[currentLocationId]

          # Initialize location state if this is first time at location.
          @gameState()?.locations[currentLocationId] = @_currentLocation.initialState() unless state

          @_currentLocation.state state

        @currentLocation @_currentLocation

    # Similar to location, create the active item.
    @activeItemId = new ReactiveField null

    # HACK: ComputedField triggers recomputation when called from events so we use ReactiveField + autorun manually.
    @activeItem = new ReactiveField null
    @autorun (computation) =>
      activeItemId = @activeItemId()

      Tracker.nonreactive =>
        # Active item is not the same, so deactivate it if we have one.
        @_activeItem?.deactivate()

        return unless activeItemId

        activeItemClass = LOI.Adventure.Item.getClassForID activeItemId

        # Create the new item and activate it.
        @_activeItem = new activeItemClass adventure: @

        Tracker.autorun (computation) =>
          @_activeItem.state @gameState()?.player.inventory[activeItemId]

        @_activeItem.activate()

        @activeItem @_activeItem

    # Create inventory.
    @inventory = new LOI.StateNode
      adventure: @
      class: LOI.Adventure.Item

    # Reactively update inventory state.
    @autorun (computation) =>
      @inventory.state @gameState()?.player.inventory

    @interface = new LOI.Adventure.Interface.Text adventure: @
    @parser = new LOI.Adventure.Parser adventure: @

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
          # We are at a location. Deactivate an item if there was one activated via URL.
          @activeItemId null

          if locationClass isnt @currentLocation()?.constructor
            # We are at a location. Switch to it.
            @currentLocationId locationClass.id()

        if itemClass
          # We are trying to use an item. See if we have it in the inventory.
          if @state().player.inventory[itemClass.id()]
            @activeItemId itemClass.id()

          else
            # We can't use an item we don't have. Return the URL to the location.
            @constructor.goToLocation @currentLocationId()

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
