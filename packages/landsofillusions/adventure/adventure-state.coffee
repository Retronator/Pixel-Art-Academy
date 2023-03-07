AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
LOI = LandsOfIllusions
Persistence = Artificial.Mummification.Document.Persistence

class LOI.Adventure extends LOI.Adventure
  @debugState = false
  
  getLocalSyncedStorage: -> null # Override to return a synced storage that will save the game locally.
  getServerSyncedStorage: -> null # Override to return a synced storage that will save the game to the server.

  _initializeState: ->
    # Prepare local and server storage.
    @localSyncedStorage = @getLocalSyncedStorage()
    Persistence.registerSyncedStorage @localSyncedStorage if @localSyncedStorage
    
    @serverSyncedStorage = @getServerSyncedStorage()
    Persistence.registerSyncedStorage @serverSyncedStorage if @serverSyncedStorage
    
    # Prepare profile handling.
    @availableProfiles = new ComputedField =>
      Persistence.availableProfiles()
      
    @profileId = new ReactiveField null
    
    # Provide game state fields.
    @gameState = new ComputedField =>
      return unless profileId = @profileId()
      LOI.GameState.documents.findOne({profileId})?.state
  
    @readOnlyGameState = new ComputedField =>
      return unless profileId = @profileId()
      LOI.GameState.documents.findOne({profileId})?.readOnlyState
      
  startNewGame: ->
    # Create a fresh profile and reset the game.
    Persistence.createNewProfile().then (profileId) ->
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
    @activeItemId null unless options.preserveActiveItem

    # Cleanup storyline classes.
    @resetEpisodes()

    # Cleanup running scripts.
    @director.stopAllScripts()

    # Activate the new profile.
    @profileId profileId
  
  saveGame: (options) ->
    # Start syncing the profile to desired storages.
    if options.local
      Persistence.addSyncingToProfile @localSyncedStorage.id()
      
    if options.server
      Persistence.addSyncingToProfile @serverSyncedStorage.id()

  quitGame: (options = {}) ->
    @quitting true
  
    Persistence.unloadProfile().then =>
      # Execute the callback if present and end if it has handled the redirect.
      return if options.callback?()
  
      # Do a hard reload of the root URL.
      window.location = @constructor.rootUrl()
