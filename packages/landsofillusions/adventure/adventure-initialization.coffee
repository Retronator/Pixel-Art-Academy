AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  @register 'LandsOfIllusions.Adventure'

  constructor: ->
    super

    console.log "Adventure constructed." if LOI.debug

    @scriptHelpers = new LOI.Adventure.Script.Helpers @

    @menu = new LOI.Components.Menu
      adventure: @

    @_modalDialogs = []
    @_modalDialogsDependency = new Tracker.Dependency

  onCreated: ->
    super

    console.log "Adventure created." if LOI.debug

    $('html').addClass('adventure')

    @interface = new LOI.Adventure.Interface.Text adventure: @
    @parser = new LOI.Adventure.Parser adventure: @

    @_initializeState()
    @_initializeCurrentLocation()
    @_initializeActiveItem()
    @_initializeInventory()
    @_initializeRouting()

  onRendered: ->
    super

    console.log "Adventure rendered." if LOI.debug

  onDestroyed: ->
    super

    console.log "Adventure destroyed." if LOI.debug

    $('html').removeClass('adventure')
