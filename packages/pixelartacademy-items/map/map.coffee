AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary
Directions = Vocabulary.Keys.Directions

class PAA.Items.Map extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Items.Map'
  @url: -> 'map'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "adventure map"
  @shortName: -> "map"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's a mental map of all the locations you've been to. Your brain is so cool!
    "

  @initialize()

  constructor: ->
    super

    # The map is active, but not visible by default.
    @activatedState LOI.Adventure.Item.activatedStates.Activated
    @bigMap = new ReactiveField false
    @miniMap = @state.field 'showMinimap'
    @fullscreenOverlay = new ReactiveField false

    $(document).on 'keydown.map', (event) =>
      @onKeyDown event

    $(document).on 'keyup.map', (event) =>
      @onKeyUp event

    @size = new ReactiveField null, EJSON.equals

    @northLocation = new ReactiveField false
    @southLocation = new ReactiveField false
    @anyNorthLocations = new ReactiveField false
    @anySouthLocations = new ReactiveField false
    @specialLocations = new ReactiveField {}

    @locations = new ComputedField =>
      return unless currentLocation = LOI.adventure.currentLocation()
      return unless currentSituation = LOI.adventure.currentSituation()

      # Build a map of locations with their avatars.
      locations =
        "#{currentLocation.id()}":
          _id: currentLocation.id()
          avatar: currentLocation.avatar
          current: true

      if exits = currentSituation.exits()
        for exitDirection, exitClass of exits
          exitId = exitClass.id()

          locations[exitId] ?=
            _id: exitId
            avatar: LOI.adventure.getAvatar exitClass

          switch exitDirection
            when Directions.In, Directions.Out, Directions.Up, Directions.Down
              locations[exitId].specialDirection = exitDirection

            else
              locations[exitId].direction = exitDirection

        # Mark any special locations that aren't being positioned in the normal 8 directions.
        specialLocations = {}
        northLocation = exits[Directions.North]?
        southLocation = exits[Directions.South]? or exits[Directions.Back]?
        anyNorthLocation = exits[Directions.Northwest]? or exits[Directions.North]? or exits[Directions.Northeast]?
        anySouthLocation = exits[Directions.Southwest]? or exits[Directions.South]? or exits[Directions.Southeast]?

        for locationId, location of locations
          if location.specialDirection and not location.direction
            specialLocations[location.specialDirection] = true

        # Set special positioning on special nodes if they must appear side-by-side
        if specialLocations[Directions.In] and specialLocations[Directions.Up] and (not anyNorthLocation or northLocation)
          locations[exits[direction].id()].specialPositioning = true for direction in [Directions.In, Directions.Up]

        if specialLocations[Directions.Out] and specialLocations[Directions.Down] and (not anySouthLocation or southLocation)
          locations[exits[direction].id()].specialPositioning = true for direction in [Directions.Out, Directions.Down]

        # Set extra location variables.
        @northLocation northLocation
        @southLocation southLocation
        @anyNorthLocations anyNorthLocation
        @anySouthLocations anySouthLocation
        @specialLocations specialLocations

      # Return just a list of locations and sort them by _id to prevent re-rendering.
      _.sortBy _.values(locations), '_id'

  destroy: ->
    super

    $(document).off '.map'

  isVisible: -> false
    
  onRendered: ->
    super

    # Resize elements.
    @autorun (computation) =>
      scale = LOI.adventure.interface.display.scale()
      viewport = LOI.adventure.interface.display.viewport()
      viewportSize = viewport.viewportBounds

      # Background can be at most 360px * scale high.
      maxOverlayHeight = 360 * scale
      maxBoundsHeight = viewport.maxBounds.height()
      gapHeight = (maxBoundsHeight - maxOverlayHeight) / 2
      cropBarHeight = Math.max 0, viewport.maxBounds.top() + gapHeight

      # Put the UI as a zero height origin at the bottom of the overlay viewport.
      @$('.user-interface').css
        left: viewportSize.left()
        width: viewportSize.width()
        top: viewportSize.bottom() - cropBarHeight

      return unless minimapSize = LOI.adventure.interface.minimapSize()

      mapSize = if @miniMap() and not @bigMap() then minimapSize else viewportSize

      @$('.map-content').css mapSize.toDimensions()

      @size mapSize

  open: ->
    LOI.adventure.goToItem @
    @fullscreenOverlay true

  onActivate: (finishedDeactivatingCallback) ->
    # Start enlarging the map.
    @bigMap true
    finishedDeactivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # Start minifying the map right away.
    @bigMap false

    Meteor.setTimeout =>
      # We only need to jump out of fullscreen and leave the map active.
      @fullscreenOverlay false
      @activatedState LOI.Adventure.Item.activatedStates.Activated
    ,
      500

  miniMapClass: ->
    'mini-map' if @miniMap() and not @bigMap()

  bigMapClass: ->
    # We need to have big-map present even when big map is not shown so that elements don't resize when hiding the map.
    'big-map' if @bigMap() or not @miniMap()

  visibleClass: ->
    busyConditions = [
      not LOI.adventure.interface.active()
      LOI.adventure.interface.waitingKeypress()
      LOI.adventure.interface.showDialogSelection()
    ]

    # Don't show the mini map if interface is busy.
    'visible' if @bigMap() or @miniMap() and not _.some busyConditions

  inIntroClass: ->
    'in-intro' if LOI.adventure.interface.inIntro()

  userInterfaceVisibleClass: ->
    # UI is shown only on the big map when it's in fullscreen mode (not peek).
    'visible' if @bigMap() and @fullscreenOverlay()

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

    if @bigMap()
      # The map is visible, close it down.
      LOI.adventure.deactivateCurrentItem()

    else
      # The map is hidden, show it.
      @bigMap true

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
    return unless @bigMap()

    # When we're just peeking at the map, close it on key up.
    if @_peekMode
      @bigMap false

    else
      # We're definitely trying to open the map, so show the fullscreen overlay.
      @open()

  # Listener

  onCommand: (commandResponse) ->
    map = @options.parent

    action = => map.open()

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.Show], map.avatar]
      priority: 1
      action: action

    commandResponse.onExactPhrase
      form: [map.avatar]
      action: action

  # Components

  class @ShowMinimap extends AM.DataInputComponent
    @register 'PixelArtAcademy.Items.Map.ShowMinimap'
    
    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Checkbox

    load: ->
      PAA.Items.Map.state 'showMinimap'

    save: (value) ->
      PAA.Items.Map.state 'showMinimap', value
