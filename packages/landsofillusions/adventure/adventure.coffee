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

    _gameStateUpdatedDependency = new Tracker.Dependency

    _gameStateUpdated = null

    @_gameState = new ComputedField =>
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

      console.log "Did we find a game state for the current user? It's currently", gameState if LOI.debug

      if gameState
        state = gameState.state
        _gameStateUpdated = (options) =>
          gameState.updated options
          _gameStateUpdatedDependency.changed()

      else
        # Fallback to local storage until we have a state from the database.
        state = @_localGameState.state()
        _gameStateUpdated = (options) =>
          # Local game state does not need to be flushed.
          return if options?.flush

          @_localGameState.updated()
          _gameStateUpdatedDependency.changed()

      # Initialize state if needed.
      unless state.initialized
        # It's our first time playing Pixel Art Academy. Start with a wallet in the inventory.
        @initializeGameState state

        Tracker.nonreactive =>
          _gameStateUpdated()

      # Flush updates in the previous state.
      Tracker.nonreactive =>
        @gameState?.updated flush: true

      # Set the new updated function.
      @gameState?.updated = _gameStateUpdated

      console.log "New game state has been set.", state if LOI.debug

      state

    # To deal with delayed updates of game state from the database (the document gets refreshed with a throttled
    # schedule) we create a game state variable that is changed every time the game state gets updated from the
    # database (new document from @_gameState) or if it was just updated locally.
    @gameState = new ComputedField =>
      _gameStateUpdatedDependency.depend()
      @_gameState()

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

          # Initialize location state if this is first time at location or the location is at a new version.
          targetVersion = currentLocationClass.version()
          unless state?.version is targetVersion
            existingState = state or {}
            state = _.merge @_currentLocation.initialState(), existingState, version: targetVersion

            gameState.locations[currentLocationId] = state

            console.log "Initialized location", currentLocationId, "with state", state if LOI.debug

            Tracker.nonreactive => @gameState.updated()

          @_currentLocation.state state

        @currentLocation @_currentLocation

    # Similar to location, create the active item.
    @activeItemId = new ReactiveField null

    # HACK: ComputedField triggers recomputation when called from events so we use ReactiveField + autorun manually.
    @activeItem = new ReactiveField null
    @autorun (computation) =>
      # Wait until location is ready and all things at location have loaded.
      currentLocation = @currentLocation()
      return unless currentLocation?.ready()

      activeItemId = @activeItemId()

      console.log "Active item ID changed to", activeItemId if LOI.debug

      console.log "Do we have an active item to deactivate?", @_activeItem if LOI.debug
      # Active item is not the same, so deactivate the current one if we have one.
      @_activeItem?.deactivate()

      # Do we even have the new item or did we switch to no item?
      if activeItemId
        # We do have an item, so find it in the inventory or at the location.
        @_activeItem = (@inventory activeItemId) or (currentLocation.things activeItemId)

        console.log "Did we find the new active item?", @_activeItem if LOI.debug

        if @_activeItem
          @_activeItem.activate()

        else
          # We can't use an item we don't have or see. Return the URL to the location.
          @constructor.goToLocation @currentLocationId()

      else
        # No more object
        @_activeItem = null

      @activeItem @_activeItem

    # Create inventory.
    @inventory = new LOI.StateNode
      adventure: @

    # Reactively update inventory state.
    @autorun (computation) =>
      console.log "Setting updated inventory state to the inventory object.", @gameState()?.player.inventory if LOI.debug

      @inventory.updateState @gameState()?.player.inventory

    @interface = new LOI.Adventure.Interface.Text adventure: @
    @parser = new LOI.Adventure.Parser adventure: @

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

      console.log "URL has changed to", url if LOI.debug

      # We only want to react to router changes.
      Tracker.nonreactive =>
        # Find if this is an item or location.
        constructor = LOI.Adventure.Thing.getClassForUrl url

        console.log "Thing class for this URL is", constructor if LOI.debug

        unless constructor
          # We didn't find a thing for this URL so return it to current state.
          @rewriteUrl()
          return

        if constructor.prototype instanceof LOI.Adventure.Location
          # We are at a location. Deactivate an item if there was one activated via URL.
          @activeItemId null

          if constructor isnt @currentLocation()?.constructor
            # We are at a location. Switch to it.
            @currentLocationId constructor.id()

        else if constructor.prototype instanceof LOI.Adventure.Item
          console.log "Thing is an item with id", constructor.id()
          @activeItemId constructor.id()

    # Make sure we're at the right URL after initialization is done.
    Tracker.afterFlush =>
      @rewriteUrl()

  onRendered: ->
    super

    console.log "Adventure rendered." if LOI.debug

  onDestroyed: ->
    super

    console.log "Adventure destroyed." if LOI.debug

    $('html').removeClass('lands-of-illusions-style-adventure')

  ready: ->
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

  logout: ->
    # Notify game state that it should flush any cached updates.
    @gameState?.updated flush: true

    # Log out the user.
    Meteor.logout()

  @goToLocation: (locationClassOrId) ->
    console.log "Routing to location with ID", locationClassOrId if LOI.debug

    locationId = if _.isFunction locationClassOrId then locationClassOrId.id() else locationClassOrId
    locationClass = LOI.Adventure.Location.getClassForID locationId
    FlowRouter.go 'LandsOfIllusions.Adventure', locationClass.urlParameters()

  @goToItem: (itemClassOrId) ->
    itemId = if _.isFunction itemClassOrId then itemClassOrId.id() else itemClassOrId
    itemClass = LOI.Adventure.Item.getClassForID itemId
    FlowRouter.go 'LandsOfIllusions.Adventure', itemClass.urlParameters()

  # Rewrites the URL to match the current item or location we're at.
  rewriteUrl: ->
    activeItemId = @activeItemId()

    console.log "Rerouting to URL for item", activeItemId, "or location", @currentLocationId() if LOI.debug

    if activeItemId
      LOI.Adventure.goToItem activeItemId

    else
      LOI.Adventure.goToLocation @currentLocationId()

  deactivateCurrentItem: ->
    # We simply go back to the URL of the current location since that will deactivate the currently active item.
    @constructor.goToLocation @currentLocation().id()
