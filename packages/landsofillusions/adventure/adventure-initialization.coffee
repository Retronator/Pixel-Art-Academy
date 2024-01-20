AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
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
      itemsClass: @constructor.menuItemsClass()

    @_modalDialogs = []
    @_modalDialogsDependency = new Tracker.Dependency

    # Adventure's end run should happen last.
    @endRunOrder = 1000

  onCreated: ->
    super arguments...

    console.log "Adventure created." if LOI.debug

    @app = @ancestorComponentOfType AB.App
    @app.addComponent @

    $('html').addClass('adventure')

    @interface = new (@constructor.interfaceClass())
    @director = new LOI.Director
    
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

    LOI.adventureInitialized true

  onRendered: ->
    super arguments...

    console.log "Adventure rendered." if LOI.debug

    # Only initialize routing after we've rendered adventure so that the persistent components
    # (such as the menu) got rendered and had the chance to register their URL handlers.
    @_initializeRouting()

    # Require the user to be signed in if local state is not allowed.
    unless @usesLocalState()
      @menu.loadGame.show()

  onDestroyed: ->
    super arguments...

    @app.removeComponent @

    Meteor.clearInterval @_gameTimeInterval

    LOI.adventure = null
    LOI.adventureInitialized false

    console.log "Adventure destroyed." if LOI.debug

    $('html').removeClass('adventure')

  endRun: ->
    # Flush persistent document updates when the page is about to unload.
    AMu.Document.Persistence.flushUpdates()
