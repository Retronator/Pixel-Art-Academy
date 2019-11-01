AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Pico8.Drawer extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Pico8.Drawer'
  @register @id()

  constructor: (@pico8) ->
    super arguments...

    @opened = new ReactiveField false
    @pannedLeft = new ReactiveField false
    @selectedCartridge = new ReactiveField null

  onCreated: ->
    super arguments...

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
    super arguments...

    # Open the drawer on app launch.
    Meteor.setTimeout =>
      @opened true
    ,
      500

  onDestroyed: ->
    super arguments...

    cartridge.destroy() for id, cartridge of @_cartridges

  cartridgeImageUrl: ->
    cartridge = @currentData()

    return unless url = cartridge.cartridgeImageUrl()

    # Don't cache local carts.
    if url.indexOf('pico8/cartridge.png') > 0
      url += "&runId=#{@_runId}"

    url

  deselectCartridge: ->
    @selectedCartridge null
    @pannedLeft false

  cartridgeShareUrl: ->
    cartridge = @currentData()
    cartridge.shareUrl()

  openedClass: ->
    'opened' if @opened()

  coveredClass: ->
    'covered' if @pico8.cartridge()

  activeClass: ->
    'active' if @selectedCartridge()

  pannedLeftClass: ->
    'panned-left' if @pannedLeft()

  selectedClass: ->
    cartridge = @currentData()

    'selected' if cartridge is @selectedCartridge()

  events: ->
    super(arguments...).concat
      'click': @onClick
      'click .cartridge': @onClickCartridge
      'click .selected-cartridge .memory-card': @onClickSelectedCartridgeMemoryCard
      'click .selected-cartridge .case-top': @onClickSelectedCartridgeCaseTop
      'click .selected-cartridge .case-bottom': @onClickSelectedCartridgeCaseBottom

  onClick: (event) ->
    return unless @selectedCartridge()

    $target = $(event.target)
    return if $target.closest('.selected-cartridge').length

    @deselectCartridge()

  onClickCartridge: (event) ->
    cartridge = @currentData()
    @selectedCartridge cartridge

  onClickSelectedCartridgeMemoryCard: (event) ->
    if @pannedLeft()
      @pannedLeft false
      return

    @pico8.cartridge @selectedCartridge()

  onClickSelectedCartridgeCaseTop: (event) ->
    @pannedLeft true

  onClickSelectedCartridgeCaseBottom: (event) ->
    @pannedLeft false
