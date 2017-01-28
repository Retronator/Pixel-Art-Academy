AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  # We call register here because this is the last of the adventure
  # coffee files included (final child in the inheritance chain).
  @register 'LandsOfIllusions.Adventure'

  constructor: ->
    super

    # Set the global instance.
    LOI.adventure = @

    console.log "Adventure constructed." if LOI.debug

    @scriptHelpers = new LOI.Adventure.Script.Helpers @

    @menu = new LOI.Components.Menu

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
    @_initializeCurrentLocation()
    @_initializeActiveItem()
    @_initializeInventory()

  onRendered: ->
    super

    console.log "Adventure rendered." if LOI.debug

    # Only initialize routing after we've rendered adventure so that the persistent components 
    # (such as the menu) got rendered and had the chance to register their URL handlers.
    @_initializeRouting()

  onDestroyed: ->
    super

    console.log "Adventure destroyed." if LOI.debug

    $('html').removeClass('adventure')
