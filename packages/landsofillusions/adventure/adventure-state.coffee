AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  @GameStateSourceType:
    LocalStorage: 'LocalStorage'
    Database: 'Database'
  
  _initializeState: ->
    # Game state depends on whether the user is signed in or not and returns
    # the game  state from database when signed in or from local storage otherwise.
    @localGameState = new LOI.LocalGameState
    
    @gameStateSource = new ReactiveField null

    _gameStateUpdatedDependency = new Tracker.Dependency

    _gameStateUpdated = null

    _gameStateProvider = new ComputedField =>
      userId = Meteor.userId()
      console.log "Game state provider is recomputing. User ID is", userId if LOI.debug

      # Subscribe to user's game state and store subscription
      # handle so we can know when the game state should be ready.
      @gameStateSubsription = Meteor.subscribe LOI.GameState.forCurrentUser
      console.log "Subscribed to game state from the database. Subscription:", @gameStateSubsription, "Is it ready?", @gameStateSubsription.ready() if LOI.debug
        
      # Find the state from the database. This creates a dependency on game state document updates.
      gameState = LOI.GameState.documents.findOne 'user._id': userId

      console.log "We currently have these game state documents:", LOI.GameState.documents.find().fetch() if LOI.debug
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
        @gameStateSource @constructor.GameStateSourceType.Database

        state = gameState.state
        
        _gameStateUpdated = (options) =>
          gameState.updated options
          _gameStateUpdatedDependency.changed()

      else if userId and not @gameStateSubsription.ready()
        # Looks like we're loading the state from the database during initial setup, so just wait.
        console.log "Waiting for game state subscription to complete." if LOI.debug

        @gameStateSource null

        state = null
        _gameStateUpdated = => # Dummy function.

      else
        # Fallback to local storage.
        @gameStateSource @constructor.GameStateSourceType.LocalStorage

        # This creates a dependency on local game state updates.
        state = @localGameState.state()
        
        _gameStateUpdated = (options) =>
          # Local game state does not need to be flushed, so just return when that command is given.
          return if options?.flush

          @localGameState.updated()
          _gameStateUpdatedDependency.changed()

      # Flush updates in the previous state.
      Tracker.nonreactive =>
        @gameState?.updated flush: true

      # Set the new updated function.
      @gameState?.updated = _gameStateUpdated

      console.log "%cNew game state has been set.", 'background: SlateGrey; color: white', state if LOI.debug

      state
      
    # To deal with delayed updates of game state from the database (the document gets refreshed with a throttled
    # schedule) we create a game state variable that is changed every time the game state gets updated locally, as
    # well as from the database (new document coming from @_gameStateProvider).
    @gameState = new ComputedField =>
      _gameStateUpdatedDependency.depend()
      _gameStateProvider()

    # Set the updated function for the first time.
    @gameState.updated = _gameStateUpdated

    # Flush the state updates to the database when the page is about to unload.
    window.onbeforeunload = =>
      @gameState?.updated flush: true
      
  clearGameState: ->
    switch @gameStateSource()
      when @constructor.GameStateSourceType.Database
        LOI.GameState.clearForCurrentUser()

      when @constructor.GameStateSourceType.LocalStorage
        @clearLocalGameState()

  clearLocalGameState: ->
    @localGameState.state {}

  isGameStateEmpty: ->
    # Save game is empty when the game isn't marked as started.
    gameState = @gameState()

    not gameState.gameStarted
