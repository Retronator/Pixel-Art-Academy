AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  @register 'LandsOfIllusions.Adventure'

  constructor: ->
    super

    console.log "Adventure constructed." if LOI.debug

  onCreated: ->
    super

    console.log "Adventure created." if LOI.debug

    # Game state depends on whether the user is signed in or not and returns
    # the game  state from database when signed in or from local storage otherwise.
    @_localGameState = new LOI.LocalGameState

    _gameStateUpdated = null

    @gameState = new ComputedField =>
      userId = Meteor.userId()

      console.log "Game state provider is recomputing. User ID is", userId if LOI.debug

      if userId
        # Subscribe to user's game state and store subscription 
        # handle so we can know when the game state should be ready.
        @gameStateSubsription = Meteor.subscribe 'LandsOfIllusions.GameState.forCurrentUser'

        console.log "Subscribed to game state from the database. Subscription:", @gameStateSubsription, "Is it ready?", @gameStateSubsription.ready() if LOI.debug
        
      # Find the state from the database.
      console.log "We currently have these game state documents:", LOI.GameState.documents.find().fetch() if LOI.debug

      gameState = LOI.GameState.documents.findOne('user._id': userId)

      console.log "Did we find a game state for he current user? It's currently", gameState if LOI.debug

      if gameState
        state = gameState.state
        _gameStateUpdated = => gameState.updated()

      else
        # Fallback to local storage until we have a state from the database.
        state = @_localGameState.state()
        _gameStateUpdated = => @_localGameState.updated()

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

      # Set the updated function.
      @gameState?.updated = _gameStateUpdated

      console.log "New game state has been set.", state if LOI.debug

      state

    # Set the updated function for the first time.
    @gameState.updated = _gameStateUpdated

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

    # Go to location where we left off after initialization is done.
    Tracker.afterFlush =>
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

        console.log "Creating new location with ID", currentLocationClass.id() if LOI.debug

        # Create a non-reactive reference so we can refer to it later.
        @_currentLocation = new currentLocationClass adventure: @

        # Reactively provide the state to the location.

        Tracker.autorun (computation) =>
          return unless gameState = @gameState()

          state = gameState.locations[currentLocationId]

          # Initialize location state if this is first time at location.
          unless state
            state = @_currentLocation.initialState()
            gameState.locations[currentLocationId] = state
            
            Tracker.nonreactive => @gameState.updated()

          @_currentLocation.state state

        @currentLocation @_currentLocation

    # Similar to location, create the active item.
    @activeItemId = new ReactiveField null

    # HACK: ComputedField triggers recomputation when called from events so we use ReactiveField + autorun manually.
    @activeItem = new ReactiveField null
    @autorun (computation) =>
      activeItemId = @activeItemId()

      console.log "Active item ID changed to", activeItemId if LOI.debug

      console.log "Do we have an active item to deactivate?", @_activeItem if LOI.debug
      # Active item is not the same, so deactivate the current one if we have one.
      @_activeItem?.deactivate()

      # Do we even have the new item or did we switch to no item?
      if activeItemId
        # We do have an item, so find it in the inventory.
        @_activeItem = @inventory[activeItemId]

        console.log "We have a new active item.", @_activeItem if LOI.debug

        @_activeItem.activate()

      else
        # No more object
        @_activeItem = null

      @activeItem @_activeItem

    # Create inventory.
    @inventory = new LOI.StateNode
      adventure: @
      class: LOI.Adventure.Item

    # Reactively update inventory state.
    @autorun (computation) =>
      console.log "Setting updated inventory state to the inventory object.", @gameState()?.player.inventory if LOI.debug

      @inventory.updateState @gameState()?.player.inventory

    @interface = new LOI.Adventure.Interface.Text adventure: @
    @parser = new LOI.Adventure.Parser adventure: @

  onRendered: ->
    super

    console.log "Adventure rendered." if LOI.debug

    # Handle url changes.
    @autorun =>
      console.log "URL has changed to", location.parameters if LOI.debug

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

        console.log "URL has been converted to class. Location:", locationClass?.id(), "Item:", itemClass?.id() if LOI.debug

        if locationClass
          # We are at a location. Deactivate an item if there was one activated via URL.
          @activeItemId null

          if locationClass isnt @currentLocation()?.constructor
            # We are at a location. Switch to it.
            @currentLocationId locationClass.id()

        if itemClass
          # We are trying to use an item. See if we have it in the inventory.
          if @gameState().player.inventory[itemClass.id()]
            @activeItemId itemClass.id()

          else
            # We can't use an item we don't have. Return the URL to the location.
            @constructor.goToLocation @currentLocationId()

  onDestroyed: ->
    super

    console.log "Adventure destroyed." if LOI.debug

    $('html').removeClass('lands-of-illusions-style-adventure')

  ready: ->
    @parser.ready() and @currentLocation()?.ready()

  @goToLocation: (locationClassOrId) ->
    console.log "Routing to location with ID", locationClassOrId if LOI.debug

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
