LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary
Directions = Vocabulary.Keys.Directions

class PAA.Items.Map extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Items.Map'
  @url: -> 'map'
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

    # The map is active, but not fullscreen by default.
    @activatedState LOI.Adventure.Item.activatedStates.Activated
    @miniMap = new ReactiveField true
    @fullscreenOverlay = new ReactiveField false

    @size = new ReactiveField null, EJSON.equals

    @anyNorthLocations = new ReactiveField false
    @anySouthLocations = new ReactiveField false

    @locations = new ComputedField =>
      return unless currentLocation = LOI.adventure.currentLocation()

      # Build a map of locations with their avatars.
      locations =
        "#{currentLocation.id()}":
          _id: currentLocation.id()
          avatar: currentLocation.avatar
          current: true

      # TODO: Get exits from current situation so they can be dynamically modified.
      for exitId, exitAvatar of currentLocation.exitAvatarsByLocationId()
        locations[exitId] =
          _id: exitId
          avatar: exitAvatar

      # Add direction data to locations.
      anyNorthLocations = false
      anySouthLocations = false

      for exitDirection, exitClass of currentLocation.exits()
        exitId = exitClass.id()

        switch exitDirection
          when Directions.In, Directions.Out, Directions.Up, Directions.Down
            locations[exitId].specialDirection = exitDirection

          else
            locations[exitId].direction = exitDirection

        switch exitDirection
          when Directions.Northwest, Directions.North, Directions.Northeast
            anyNorthLocations = true

          when Directions.Southwest, Directions.South, Directions.Southeast
            anySouthLocations = true

      # Set extra location variables.
      @anyNorthLocations anyNorthLocations
      @anySouthLocations anySouthLocations

      # Return just a list of locations and sort them by _id to prevent re-rendering.
      _.sortBy _.values(locations), '_id'

  isVisible: -> false
    
  onRendered: ->
    super

    # Resize elements.
    @autorun (computation) =>
      viewport = LOI.adventure.interface.display.viewport()

      viewportSize = viewport.viewportBounds
      return unless minimapSize = LOI.adventure.interface.minimapSize()

      mapSize = if @miniMap() then minimapSize else viewportSize

      @$('.map-content').css mapSize.toDimensions()

      @size mapSize

  onActivate: (finishedDeactivatingCallback) ->
    # Start enlarging the map.
    @miniMap false
    finishedDeactivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # Start minifying the map right away.
    @miniMap true

    Meteor.setTimeout =>
      # We only need to jump out of fullscreen and leave the map active.
      @fullscreenOverlay false
      @activatedState LOI.Adventure.Item.activatedStates.Activated
    ,
      500

  minimapClass: ->
    'mini-map' if @miniMap()

  visibleClass: ->
    # Don't show the mini map if interface is only showing the description.
    'visible' unless LOI.adventure.interface.inIntro()
    
  # Listener

  onCommand: (commandResponse) ->
    map = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], map.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem map
        map.fullscreenOverlay true
