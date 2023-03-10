AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
LOI = LandsOfIllusions
Persistence = Artificial.Mummification.Document.Persistence

class LOI.Adventure extends LOI.Adventure
  @debugState = false
  @profileIdLocalStorageKey = 'LandsOfIllusions.Adventure.profileId'
  
  getLocalSyncedStorage: -> null # Override to return a synced storage that will save the game locally.
  getServerSyncedStorage: -> null # Override to return a synced storage that will save the game to the server.

  _initializeState: ->
    # Prepare local and server storage.
    @localSyncedStorage = @getLocalSyncedStorage()
    Persistence.registerSyncedStorage @localSyncedStorage if @localSyncedStorage
    
    @serverSyncedStorage = @getServerSyncedStorage()
    Persistence.registerSyncedStorage @serverSyncedStorage if @serverSyncedStorage
    
    # Prepare profile handling.
    @profileId = new ReactiveField null
    
    @profile = new ComputedField =>
      Persistence.Profile.documents.findOne @profileId()
    
    # Provide game state fields.
    @gameState = new ComputedField =>
      return unless profileId = @profileId()
      
      gameState = LOI.GameState.documents.findOne({profileId}, fields: state: 1)?.state or {}
      console.log "Retrieved new game state", gameState if LOI.debug or LOI.Adventure.debugState
      gameState
  
    @gameState.updated = =>
      return unless profileId = @profileId()
      
      gameState = @gameState()
      console.log "Game state updated, sending to documents ...", gameState if LOI.debug or LOI.Adventure.debugState
      LOI.GameState.documents.update {profileId}, $set: state: gameState
  
    @readOnlyGameState = new ComputedField =>
      return unless profileId = @profileId()
      
      readOnlyGameState = LOI.GameState.documents.findOne({profileId}, fields: readOnlyState: 1)?.readOnlyState or {}
      console.log "Retrieved new read only game state", readOnlyGameState if LOI.debug or LOI.Adventure.debugState
      readOnlyGameState
      
    # See if we have a profile ID stored locally.
    # if profileId = @_loadStoredProfileId()
    #   @loadGame profileId

  startNewGame: ->
    # Create a fresh profile and reset the game.
    Persistence.createProfile().then (profileId) =>
      # Create a new game state.
      LOI.GameState.documents.insert {profileId}
      
      @_changeProfileId profileId
  
  loadGame: (profileId) ->
    # Load the game profile from persistence and activate it.
    Persistence.loadProfile(profileId).then =>
      console.log "Profile successfully loaded"
      @_changeProfileId profileId
      
    , (conflictResolution) =>
      console.log "Resolve conflict", conflictResolution
      
  _changeProfileId: (profileId) ->
    # Reset the interface.
    @interface.reset()

    # Clear active item.
    @activeItemId null

    # Cleanup storyline classes.
    @resetEpisodes()

    # Cleanup running scripts.
    @director.stopAllScripts()

    # Activate the new profile.
    @profileId profileId
  
  saveGame: (options) ->
    # Start syncing the profile to desired storages.
    if options.local and @localSyncedStorage
      Persistence.addSyncingToProfile @localSyncedStorage.id()
      
    if options.server and @serverSyncedStorage
      Persistence.addSyncingToProfile @serverSyncedStorage.id()
  
    # Store profile ID locally.
    @_storeProfileId()

  quitGame: (options = {}) ->
    @profileId null
    @_clearStoredProfileId()
  
    Persistence.unloadProfile().then =>
      # Execute the callback if present and end if it has handled the redirect.
      return if options.callback?()
  
      # Do a hard reload of the root URL.
      window.location = @constructor.rootUrl()
      
  _loadStoredProfileId: ->
    localStorage.getItem @constructor.profileIdLocalStorageKey
    
  _storeProfileId: ->
    localStorage.setItem @constructor.profileIdLocalStorageKey, @profileId()
    
  _clearStoredProfileId: ->
    localStorage.removeItem @constructor.profileIdLocalStorageKey
