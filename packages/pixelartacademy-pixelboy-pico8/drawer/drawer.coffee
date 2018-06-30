AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Pico8.Drawer extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Pico8.Drawer'
  @register @id()

  constructor: (@pico8) ->
    super

    @opened = new ReactiveField false
    @selectedCartridge = new ReactiveField null

  onCreated: ->
    super

    # Create a random ID to prevent caching carts. We assume the art won't
    # change while in the app, to prevent constant calls to the server.
    @_runId = Random.id()

    @cartridgesLocation = new PAA.Pico8.Cartridges

    @cartridgesSituation = new ComputedField =>
      options =
        timelineId: LOI.adventure.currentTimelineId()
        location: @cartridgesLocation

      return unless options.timelineId

      new LOI.Adventure.Situation options

    # We use a cache to avoid reconstruction.
    @_cartridges = {}

    @cartridges = new ComputedField =>
      return unless cartridgesSituation = @cartridgesSituation()

      cartridgeClasses = cartridgesSituation.things()

      for cartridgeClass in cartridgeClasses
        # We create the instance in a non-reactive context so that
        # reruns of this autorun don't invalidate instance's autoruns.
        Tracker.nonreactive =>
          @_cartridges[cartridgeClass.id()] ?= new cartridgeClass

        @_cartridges[cartridgeClass.id()]

  onRendered: ->
    super

    # Open the drawer on app launch.
    Meteor.setTimeout =>
      @opened true
    ,
      500

  onDestroyed: ->
    super

    cartridge.destroy() for id, cartridge of @_cartridges

  cartridgeUrl: ->
    cartridge = @currentData()

    url = cartridge.cartridgeUrl()

    # Don't cache local carts.
    if url.indexOf('pico8/cartridge.png') > 0
      url += "&runId=#{@_runId}"

    url

  openedClass: ->
    'opened' if @opened()

  coveredClass: ->
    'covered' if @pico8.cartridge()

  activeClass: ->
    'active' if @selectedCartridge()

  selectedClass: ->
    cartridge = @currentData()

    'selected' if cartridge is @selectedCartridge()

  events: ->
    super.concat
      'click': @onClick
      'click .cartridge': @onClickCartridge
      'click .selected-cartridge': @onClickSelectedCartridge

  onClick: (event) ->
    return unless @selectedCartridge()
    return if $(event.target).closest('.selected-cartridge').length

    @selectedCartridge null

  onClickCartridge: (event) ->
    cartridge = @currentData()
    @selectedCartridge cartridge

  onClickSelectedCartridge: (event) ->
    @pico8.cartridge @selectedCartridge()
