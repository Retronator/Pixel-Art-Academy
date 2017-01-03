AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  @register 'LandsOfIllusions.Adventure'

  constructor: ->
    super

    @scriptHelpers = new LOI.Adventure.Script.Helpers @

    console.log "Adventure constructed." if LOI.debug

  onCreated: ->
    super

    console.log "Adventure created." if LOI.debug

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
