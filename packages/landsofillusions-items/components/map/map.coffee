AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary
Directions = Vocabulary.Keys.Directions

class LOI.Items.Components.Map extends AM.Component
  @id: -> 'LandsOfIllusions.Items.Components.Map'
  @register @id()

  constructor: ->
    super

    @bigMap = new ReactiveField false
    @miniMap = LOI.Items.Map.state.field 'showMinimap'
    @showUserInterface = new ReactiveField false

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

  miniMapClass: ->
    'mini-map' if @miniMap() and not @bigMap()

  bigMapClass: ->
    # We need to have big-map present even when big map is not shown so that elements don't resize when hiding the map.
    'big-map' if @bigMap() or not @miniMap()

  visibleClass: ->
    busyConditions = [
      not LOI.adventure.interface.active()
      LOI.adventure.interface.waitingKeypress()
      LOI.adventure.interface.showDialogueSelection()
    ]

    # Don't show the mini map if interface is busy.
    'visible' if @bigMap() or @miniMap() and not _.some busyConditions

  inIntroClass: ->
    'in-intro' if LOI.adventure.interface.inIntro()

  userInterfaceVisibleClass: ->
    # UI is shown only on the big map when it's in fullscreen mode (not peek).
    'visible' if @bigMap() and @showUserInterface()
