AB = Artificial.Base
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.Sync extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Items.Sync'
  @url: -> 'sync'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "SYNC"

  @description: ->
    "
      It's Neurasync's Synchronization Neural Connector, SYNC for short. It looks like a fitness tracker wristband.
    "

  @initialize()

  constructor: ->
    super

    # SYNC is active, but not visible by default.
    @activatedState LOI.Adventure.Item.activatedStates.Activated

  onCreated: ->
    super

    @mapTab = new PAA.Items.Sync.Map
    @memoriesTab = new PAA.Items.Sync.Memories

    @tabs = [
      @mapTab
      @memoriesTab
    ]

    @tabsByUrl = {}
    @tabsByUrl[tab.url()] = tab for tab in @tabs

    @currentTab = new ReactiveField @mapTab

    @fullscreenOverlay = new ReactiveField false

    $(document).on 'keydown.pixelartacademy-items-sync', (event) =>
      @onKeyDown event

    $(document).on 'keyup.pixelartacademy-items-sync', (event) =>
      @onKeyUp event

  onDestroyed: ->
    super

    $(document).off '.pixelartacademy-items-sync'

  url: ->
    url = @constructor.url()
    currentTab = @currentTab()

    # Return the URL for the tab.
    "#{url}/#{currentTab.url()}"

  isVisible: ->
    # SYNC is not visible to the character.
    not LOI.characterId()

  open: ->
    LOI.adventure.goToItem @
    @fullscreenOverlay true
    @mapTab.map.showUserInterface true

  onActivate: (finishedDeactivatingCallback) ->
    # Start enlarging the map.
    @mapTab.map.bigMap true
    finishedDeactivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # Start minifying the map right away.
    @mapTab.map.bigMap false

    Meteor.setTimeout =>
      # We only need to jump out of fullscreen and leave the map active.
      @fullscreenOverlay false
      @mapTab.map.showUserInterface false
      @activatedState LOI.Adventure.Item.activatedStates.Activated
    ,
      500

  mapTabVisibleClass: ->
    # We need to render the map when we're on its tab or when we're not in overlay.
    'visible' if @currentTab() is @mapTab or not @fullscreenOverlay()

  currentTabIsMap: ->
    @currentTab() is @mapTab

  activeTabClass: ->
    tab = @currentData()

    'active' if @currentTab() is tab

  events: ->
    super.concat
      'click .navigation .tab': @onClickNavigationTab

  onClickNavigationTab: (event) ->
    tab = @currentData()
    @currentTab tab

  onKeyDown: (event) ->
    # Don't capture events when interface is not active, unless we're the reason for it.
    return unless LOI.adventure.interface.active() or LOI.adventure.activeItem() is @

    keyCode = event.which
    return unless keyCode is AC.Keys.tab

    # Prevent all tab key down events, but only handle the first.
    event.preventDefault()
    return if @_tabIsDown

    @_tabIsDown = true
    @_peekMode = false

    if @fullscreenOverlay()
      # SYNC is open, close it down.
      LOI.adventure.deactivateActiveItem()

    else
      # SYNC is hidden, start showing the map.
      @mapTab.map.bigMap true

      # Start counting down to peek mode.
      @_mapPeekTimeout = Meteor.setTimeout =>
        @_peekMode = true
      ,
        200

  onKeyUp: (event) ->
    return unless @_tabIsDown

    keyCode = event.which
    return unless keyCode is AC.Keys.tab

    @_tabIsDown = false

    Meteor.clearTimeout @_mapPeekTimeout

    # Only react if the map in the process of showing.
    return unless @mapTab.map.bigMap()

    # When we're just peeking at the map, close it on key up.
    if @_peekMode
      @mapTab.map.bigMap false

    else
      # We're definitely trying to open the map, so show the fullscreen overlay.
      @open()

  # Listener

  @avatars: ->
    map: PAA.Items.Map

  onCommand: (commandResponse) ->
    sync = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, sync.avatar]
      action: => sync.open()

    mapAction = =>
      # TODO: Open sync in map mode.
      sync.open()

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.Show], @avatars.map]
      priority: 1
      action: mapAction

    commandResponse.onExactPhrase
      form: [@avatars.map]
      action: mapAction

  # Routing

  LOI.Adventure.registerDirectRoute "/#{@url()}/*", =>
    tabUrl = AB.Router.getParameter 'parameter2'

    # Show the item if we need to.
    unless LOI.adventure.activeItemId() is @id()
      Tracker.autorun (computation) =>
        # Wait until the item is available.
        return unless sync = LOI.adventure.getCurrentThing @
        return unless sync.isCreated()
        computation.stop()

        # Switch to correct tab.
        tab = sync.tabsByUrl[tabUrl]
        sync.currentTab sync.tabsByUrl[tabUrl] if tab

        # Show the interface.
        sync.open()
