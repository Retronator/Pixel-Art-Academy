AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  # We call register here because this is the last of the adventure
  # coffee files included (final child in the inheritance chain).
  @register @id()

  constructor: ->
    super arguments...

    # Set the global instance.
    LOI.adventure = @

    console.log "Adventure constructed." if LOI.debug

    @scriptHelpers = new LOI.Adventure.Script.Helpers @

    @menu = new LOI.Components.Menu
    
    @loggingOut = new ReactiveField false
    @quitting = new ReactiveField false

    @_modalDialogs = []
    @_modalDialogsDependency = new Tracker.Dependency

    # Adventure's end run should happen last.
    @endRunOrder = 1000

  onCreated: ->
    super arguments...

    console.log "Adventure created." if LOI.debug

    @app = @ancestorComponent Retronator.App
    @app.addComponent @

    $('html').addClass('adventure')

    @interface = new LOI.Interface.Text
    @parser = new LOI.Parser
    @director = new LOI.Director
    @world = new LOI.Engine.World adventure: @
    
    @_initializeState()

    # Memories need to be initialized first because timeline and location depends on the display of a memory.
    @_initializeMemories()

    # Timeline needs to be initialized before location, because the logic
    # for missing locations depends on the timeline to know where to move you.
    @_initializeTimeline()
    @_initializeLocation()
    @_initializeContext()

    @_initializeActiveItem()
    @_initializeEpisodes()
    @_initializeInventory()
    @_initializeThings()
    @_initializeListeners()
    @_initializeTime()
    @_initializeAssets()
    @_initializeGroups()

    LOI.adventureInitialized true

  onRendered: ->
    super arguments...

    console.log "Adventure rendered." if LOI.debug

    # Only initialize routing after we've rendered adventure so that the persistent components 
    # (such as the menu) got rendered and had the chance to register their URL handlers.
    @_initializeRouting()

    # Require the user to be signed in if local state is not allowed.
    unless @usesLocalState()
      # Because direct URL routing might have changed the active item, we need to preserve it during this initial load.
      @loadGame preserveActiveItem: true

  onDestroyed: ->
    super arguments...

    @app.removeComponent @

    Meteor.clearInterval @_gameTimeInterval

    LOI.adventure = null
    LOI.adventureInitialized false

    console.log "Adventure destroyed." if LOI.debug

    $('html').removeClass('adventure')

  endRun: ->
    # Flush the state updates to the database when the page is about to unload.
    @gameState?.updated? flush: true
    @userGameState?.updated? flush: true

    # If we're signed in, but aren't saving login information, quit game to remove all local data.
    if Meteor.userId() and not LOI.settings.persistLogin.allowed()
      @clearLocalGameState()
      @clearLocalStorageGameStateParts()
      @clearLoginInformation()
