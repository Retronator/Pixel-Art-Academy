AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  @GameStateSourceType:
    LocalStorageUser: 'LocalStorageUser'
    DatabaseUser: 'DatabaseUser'
    DatabaseCharacter: 'DatabaseCharacter'
  
  _initializeState: ->
    # Game state depends on whether the user is signed in or not and returns
    # the game state from database when signed in or from local storage otherwise.
    @localGameState = new LOI.LocalGameState
    
    @gameStateSource = new ReactiveField null

    _gameStateUpdatedDependency = new Tracker.Dependency

    _gameStateUpdated = null

    _gameStateProvider = new ComputedField =>
      userId = Meteor.userId()
      characterId = LOI.characterId()
      console.log "Game state provider is recomputing. User ID is", userId, "Character ID is", characterId if LOI.debug

      if characterId
        # Subscribe to character's game state and store subscription
        # handle so we can know when the game state should be ready.
        @gameStateSubsription = LOI.GameState.forCharacter.subscribe characterId
        console.log "Subscribed to character game state from the database. Subscription:", @gameStateSubsription, "Is it ready?", @gameStateSubsription.ready() if LOI.debug
          
        # Find the state from the database. This creates a dependency on game state document updates.
        gameState = LOI.GameState.documents.findOne 'character._id': characterId

      else
        # Subscribe to user's game state and store subscription
        # handle so we can know when the game state should be ready.
        @gameStateSubsription = LOI.GameState.forCurrentUser.subscribe()
        console.log "Subscribed to user game state from the database. Subscription:", @gameStateSubsription, "Is it ready?", @gameStateSubsription.ready() if LOI.debug
          
        # Find the state from the database. This creates a dependency on game state document updates.
        gameState = LOI.GameState.documents.findOne 'user._id': userId

      console.log "We currently have these game state documents:", LOI.GameState.documents.find().fetch() if LOI.debug
      console.log "Did we find a game state? We got", gameState if LOI.debug

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
        if characterId
          @gameStateSource @constructor.GameStateSourceType.DatabaseCharacter
          
        else
          @gameStateSource @constructor.GameStateSourceType.DatabaseUser

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

      else if characterId
        # We were waiting for a character state, but it is not present. Unload the character.
        console.log "No character state found. Unloading character." if LOI.debug

        LOI.switchCharacter null

      else
        # We were waiting for a user state, but it is not present. Fallback to local storage.
        @gameStateSource @constructor.GameStateSourceType.LocalStorageUser

        # This creates a dependency on local game state updates.
        state = @localGameState.state()
        
        _gameStateUpdated = (options) =>
          @localGameState.updated options
          _gameStateUpdatedDependency.changed()

      # Set the new updated function.
      @gameState?.updated = _gameStateUpdated

      console.log "%cNew game state has been set.", 'background: SlateGrey; color: white', state if LOI.debug

      state
      
    # To deal with delayed updates of game state from the database (the document gets refreshed with a throttled
    # schedule) we create a game state variable that is changed every time the game state gets updated locally, as
    # well as from the database (new document coming from @_gameStateProvider).
    @gameState = new ComputedField =>
      # Wait until adventure is initialized before returning anything
      # since state objects also don't return anything prior to that.
      return unless LOI.adventureInitialized()

      _gameStateUpdatedDependency.depend()
      _gameStateProvider()

    # Set the updated function for the first time.
    @gameState.updated = _gameStateUpdated

    # User game state always points to the database game state for the user. It's used when the game state points to
    # a character game state instead, but is a much simpler version that doesn't support all the features of a normal
    # game state (local storage fallback, local and database dependency trigger). Its updates are still throttled and
    # can be saved by calling the update function on the userGameState variable.
    _userGameStateUpdated = null

    _userGameStateProvider = new ComputedField =>
      # Don't allow the use of user state unless the character is loaded.
      unless LOI.characterId()
        @userGameState?.updated = => # Dummy function.
        return

      LOI.GameState.forCurrentUser.subscribe()

      userId = Meteor.userId()
      gameState = LOI.GameState.documents.findOne 'user._id': userId

      # Create update function.
      _userGameStateUpdated = (options) =>
        gameState?.updated options

      # Store the update function to the computed field variable.
      @userGameState?.updated = _userGameStateUpdated

      # Return the state in the document.
      gameState?.state

    @userGameState = new ComputedField =>
      # Wait until adventure is initialized before returning anything
      # since state objects also don't return anything prior to that.
      return unless LOI.adventureInitialized()

      _userGameStateProvider()

    # Set the updated function for the first time.
    @userGameState.updated = _userGameStateUpdated

    # Flush the state updates to the database when the page is about to unload.
    window.addEventListener 'beforeunload', (event) =>
      @gameState?.updated flush: true
      @userGameState?.updated flush: true

  replaceGameState: (newState) ->
    switch @gameStateSource()
      when @constructor.GameStateSourceType.DatabaseUser
        LOI.GameState.replaceForCurrentUser newState

      when @constructor.GameStateSourceType.DatabaseCharacter
        LOI.GameState.replaceForCharacter LOI.characterId(), newState

      when @constructor.GameStateSourceType.LocalStorageUser
        @replaceLocalGameState newState

  replaceLocalGameState: (newState) ->
    @localGameState.state newState

  clearGameState: ->
    switch @gameStateSource()
      when @constructor.GameStateSourceType.DatabaseUser
        LOI.GameState.clearForCurrentUser()

      when @constructor.GameStateSourceType.DatabaseCharacter
        LOI.GameState.clearForCharacter LOI.characterId(), newState

      when @constructor.GameStateSourceType.LocalStorageUser
        @clearLocalGameState()

  clearLocalGameState: ->
    @localGameState.state {}

  isGameStateEmpty: ->
    # Save game is empty when the game isn't marked as started.
    gameState = @gameState()

    not gameState?.gameStarted

  loadGame: ->
    # Wait until user is logged in.
    userAutorun = Tracker.autorun (computation) =>
      return unless user = Retronator.user()
      computation.stop()

      # Wait also until the game state has been loaded.
      Tracker.autorun (computation) =>
        return unless LOI.adventure.gameStateSubsription.ready()
        computation.stop()

        databaseState = LOI.GameState.documents.findOne 'user._id': user._id

        if databaseState
          # Move user to the last location and timeline saved to the state. We do this only on load so that multiple
          # players using the same account can move independently, at least inside the current session (they will get
          # synced again on reload).
          LOI.adventure.currentLocationId databaseState.state.currentLocationId
          LOI.adventure.currentTimelineId databaseState.state.currentTimelineId
          LOI.adventure.immersionExitLocationId databaseState.state.immersionExitLocationId

          LOI.adventure.menu.signIn.activatable.deactivate()

        else
          # Show dialog informing the user we're saving the local game state.
          dialog = new LOI.Components.Dialog
            message: "
              The account you loaded doesn't have a save game yet.
              Do you want to save your current game position to it?
            "
            buttons: [
              text: "Save game"
              value: true
            ,
              text: "Cancel"
            ]

          LOI.adventure.showActivatableModalDialog
            dialog: dialog
            callback: =>
              if dialog.result
                # The player has confirmed to use the local state for the loaded account.
                LOI.GameState.insertForCurrentUser LOI.adventure.localGameState.state(), =>
                  # Now that the local state has been transferred, clear it for next player.
                  LOI.adventure.clearLocalGameState()

              else
                # The player canceled. Log them out since we shouldn't continue without a game state.
                Meteor.logout()

              LOI.adventure.menu.signIn.activatable.deactivate()

    # Set sign in dialog to show sign in (and not create account) by default:
    Accounts._loginButtonsSession.set 'inSignupFlow', false
    Accounts._loginButtonsSession.set 'inForgotPasswordFlow', false

    LOI.adventure.showActivatableModalDialog
      dialog: LOI.adventure.menu.signIn
      dontRender: true
      callback: =>
        # User has returned from the load screen.
        userAutorun.stop()

  saveGame: (callback) ->
    # Wait until user is logged in.
    userAutorun = Tracker.autorun (computation) =>
      return unless user = Retronator.user()
      computation.stop()

      # Wait also until the game state has been loaded.
      Tracker.autorun (computation) =>
        return unless LOI.adventure.gameStateSubsription.ready()
        computation.stop()

        databaseState = LOI.GameState.documents.findOne 'user._id': user._id

        if databaseState
          # Show dialog informing the user that the account already has a game state and it will be overwriting it.
          dialog = new LOI.Components.Dialog
            message: "
              The account you selected already has a save game.
              Do you want to overwrite it with your current game position?
            "
            buttons: [
              text: "Overwrite"
              value: true
            ,
              text: "Cancel"
            ]

          LOI.adventure.showActivatableModalDialog
            dialog: dialog
            callback: =>
              if dialog.result
                # The player has confirmed to use the local state for the loaded account.
                LOI.GameState.replaceForCurrentUser LOI.adventure.localGameState.state(), =>
                  # Now that the local state has been transferred, clear it for next player.
                  LOI.adventure.clearLocalGameState()

              else
                # The player canceled. Log them out since we shouldn't store our game state there.
                Meteor.logout()

              LOI.adventure.menu.signIn.activatable.deactivate()

        else
          # Insert the current local state as the state for this (new) user.
          LOI.GameState.insertForCurrentUser LOI.adventure.localGameState.state(), =>
            # Now that the local state has been transferred, clear it for next player.
            LOI.adventure.clearLocalGameState()

          LOI.adventure.menu.signIn.activatable.deactivate()

    # Set sign in dialog to show create account (and not sign in) by default:
    Accounts._loginButtonsSession.set 'inSignupFlow', true
    Accounts._loginButtonsSession.set 'inForgotPasswordFlow', false

    LOI.adventure.showActivatableModalDialog
      dialog: LOI.adventure.menu.signIn
      dontRender: true
      callback: =>
        # User has returned from the load screen.
        userAutorun.stop()
        callback?()

  loadCharacter: (characterId) ->
    # Save where we're going to immersion from.
    if LOI.adventure.currentTimelineId() is PixelArtAcademy.TimelineIds.RealLife
      LOI.adventure.saveImmersionExitLocation()

    LOI.switchCharacter characterId
    @_onSwitchingGameState()

    # Give the system a chance to kick in the new game state subscription.
    Meteor.setTimeout =>
      # Wait until the character's state has been loaded.
      Tracker.autorun (computation) =>
        return unless LOI.adventure.gameStateSubsription.ready()
        computation.stop()

        databaseState = LOI.GameState.documents.findOne 'character._id': characterId

        if databaseState
          # Move player to the last location and timeline saved to the state.
          LOI.adventure.currentLocationId databaseState.state.currentLocationId
          LOI.adventure.currentTimelineId databaseState.state.currentTimelineId

        else
          console.error "Character game state is missing. Aborting."
          LOI.switchCharacter null

  unloadCharacter: ->
    LOI.switchCharacter null
    @_onSwitchingGameState()

    # Give the system a chance to kick in the new game state subscription.
    Meteor.setTimeout =>
      # Move player to the exit location in real life.
      LOI.adventure.currentLocationId LOI.adventure.immersionExitLocationId()
      LOI.adventure.currentTimelineId PixelArtAcademy.TimelineIds.RealLife

  loadConstruct: ->
    # Going to Construct differs if we're going there from the user's or character's world.
    if LOI.characterId()
      # Unload the character to get back to user state.
      LOI.switchCharacter null
      @_onSwitchingGameState()

    else
      # Save where we're going to Construct from.
      LOI.adventure.saveImmersionExitLocation()

    # Give the system a chance to kick in the new game state subscription.
    Meteor.setTimeout =>
      # Go to Construct.
      LOI.adventure.goToLocation LOI.Construct.Loading
      LOI.adventure.goToTimeline PixelArtAcademy.TimelineIds.Construct

  unloadConstruct: ->
    # Move player to the exit location in real life.
    LOI.adventure.currentLocationId LOI.adventure.immersionExitLocationId()
    LOI.adventure.currentTimelineId PixelArtAcademy.TimelineIds.RealLife

  _onSwitchingGameState: ->
    # Cleanup running scripts.
    LOI.adventure.director.stopAllScripts()
