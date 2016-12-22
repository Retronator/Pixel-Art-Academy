AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  @resetGameState: (state) ->
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
      
  _initializeState: ->
    # Game state depends on whether the user is signed in or not and returns
    # the game  state from database when signed in or from local storage otherwise.
    @_localGameState = new LOI.LocalGameState

    _gameStateUpdatedDependency = new Tracker.Dependency

    _gameStateUpdated = null

    @_gameState = new ComputedField =>
      userId = Meteor.userId()
      console.log "Game state provider is recomputing. User ID is", userId if LOI.debug

      # Subscribe to user's game state and store subscription 
      # handle so we can know when the game state should be ready.
      @gameStateSubsription = Meteor.subscribe LOI.GameState.forCurrentUser
      console.log "Subscribed to game state from the database. Subscription:", @gameStateSubsription, "Is it ready?", @gameStateSubsription.ready() if LOI.debug
        
      # Find the state from the database.
      console.log "We currently have these game state documents:", LOI.GameState.documents.find().fetch() if LOI.debug

      gameState = LOI.GameState.documents.findOne('user._id': userId)
      console.log "Did we find a game state for the current user? We got", gameState if LOI.debug

      # Here we decide which provider of the game state we'll use, the database or local storage. In general this is
      # determined by whether the user is logged in, but we also want to use local storage while user is registering.
      # In that case the user will already be logged in, but the game logic hasn't yet created the game state document,
      # so we want to continue using local storage for continuity. However, this logic needs to be written in a way that
      # this fallback isn't activated when we don't have the game state because we haven't even subscribed to receive
      # the documents. That happens when the user is logged in upon launching the site and we should simply wait (and
      # show the loading screen while doing it) until the game state is loaded and all the rest of initialization
      # (location, inventory) can happen relative to actual game state from the database (for example, whether the url
      # points to an object we have in our possession).
      if gameState
        state = gameState.state
        _gameStateUpdated = (options) =>
          gameState.updated options
          _gameStateUpdatedDependency.changed()

      else if userId and not @gameStateSubsription.ready()
        # Looks like we're loading the state from the database during initial setup, so just wait.
        console.log "Waiting for game state subscription to complete." if LOI.debug
        _gameStateUpdated = => # Dummy function.
        state = null

      else
        # Fallback to local storage.
        state = @_localGameState.state()
        _gameStateUpdated = (options) =>
          # Local game state does not need to be flushed.
          return if options?.flush

          @_localGameState.updated()
          _gameStateUpdatedDependency.changed()

      # Initialize state if needed.
      if state and not state.initialized
        # It's our first time playing Pixel Art Academy. Start with a clear state.
        LOI.Adventure.resetGameState state

        Tracker.nonreactive => _gameStateUpdated()

      # Flush updates in the previous state.
      Tracker.nonreactive =>
        @gameState?.updated flush: true

      # Set the new updated function.
      @gameState?.updated = _gameStateUpdated

      console.log "%cNew game state has been set.", 'background: SlateGrey; color: white', state if LOI.debug

      state
      
    # To deal with delayed updates of game state from the database (the document gets refreshed with a throttled
    # schedule) we create a game state variable that is changed every time the game state gets updated from the
    # database (new document from @_gameState) and when it was just updated locally.
    @gameState = new ComputedField =>
      _gameStateUpdatedDependency.depend()
      @_gameState()

    # Set the updated function for the first time.
    @gameState.updated = _gameStateUpdated

    # Flush the state updates to the database when the page is about to unload.
    window.onbeforeunload = =>
      @gameState?.updated flush: true

  clearLocalGameState: ->
    localGameState = @_localGameState.state()
    LOI.Adventure.resetGameState localGameState
    @_localGameState.updated()
