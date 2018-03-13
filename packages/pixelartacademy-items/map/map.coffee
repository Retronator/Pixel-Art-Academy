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
    @fullscreenOverlay = new ReactiveField false

    $(document).on 'keydown.pixelartacademy-items-map', (event) =>
      @onKeyDown event

    $(document).on 'keyup.pixelartacademy-items-map', (event) =>
      @onKeyUp event

  onCreated: ->
    super

    @map = new PAA.Items.Components.Map

  destroy: ->
    super

    $(document).off '.pixelartacademy-items-map'

  isVisible: -> false

  open: ->
    LOI.adventure.goToItem @
    @fullscreenOverlay true
    @map.showUserInterface true

  onActivate: (finishedDeactivatingCallback) ->
    # Start enlarging the map.
    @map.bigMap true
    finishedDeactivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # Start minifying the map right away.
    @map.bigMap false

    Meteor.setTimeout =>
      # We only need to jump out of fullscreen and leave the map active.
      @fullscreenOverlay false
      @map.showUserInterface false
      @activatedState LOI.Adventure.Item.activatedStates.Activated
    ,
      500

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

    if @map.bigMap()
      # The map is visible, close it down.
      LOI.adventure.deactivateActiveItem()

    else
      # The map is hidden, show it.
      @map.bigMap true

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
    return unless @map.bigMap()

    # When we're just peeking at the map, close it on key up.
    if @_peekMode
      @map.bigMap false

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
