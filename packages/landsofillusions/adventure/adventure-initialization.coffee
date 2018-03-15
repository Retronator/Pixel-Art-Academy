AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  # We call register here because this is the last of the adventure
  # coffee files included (final child in the inheritance chain).
  @register @id()

  constructor: ->
    super

    # Set the global instance.
    LOI.adventure = @

    console.log "Adventure constructed." if LOI.debug

    @scriptHelpers = new LOI.Adventure.Script.Helpers @

    @menu = new LOI.Components.Menu
    
    @loggingOut = new ReactiveField false
    @quitting = new ReactiveField false

    @_modalDialogs = []
    @_modalDialogsDependency = new Tracker.Dependency

  onCreated: ->
    super

    console.log "Adventure created." if LOI.debug

    $('html').addClass('adventure')

    @interface = new LOI.Interface.Text

    @parser = new LOI.Parser

    @director = new LOI.Director

    @_initializeState()

    # Memories need to be initialized first because timeline and location depends on the display of a memory.
    @_initializeMemories()

    # Timeline needs to be initialized before location, because the logic
    # for missing locations depends on the timeline to know where to move you.
    @_initializeTimeline()
    @_initializeLocation()

    @_initializeActiveItem()
    @_initializeEpisodes()
    @_initializeInventory()
    @_initializeThings()
    @_initializeListeners()
    @_initializeTime()

    LOI.adventureInitialized true

  onRendered: ->
    super

    console.log "Adventure rendered." if LOI.debug

    # Only initialize routing after we've rendered adventure so that the persistent components 
    # (such as the menu) got rendered and had the chance to register their URL handlers.
    @_initializeRouting()

    # Require the user to be signed in if local state is not allowed.
    @loadGame() unless @usesLocalState()

  onDestroyed: ->
    super

    Meteor.clearInterval @_gameTimeInterval

    LOI.adventure = null
    LOI.adventureInitialized false

    console.log "Adventure destroyed." if LOI.debug

    $('html').removeClass('adventure')
