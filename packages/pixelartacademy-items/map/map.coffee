LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

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

  isVisible: -> false

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
    
  # Listener

  onCommand: (commandResponse) ->
    map = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], map.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem map
        map.fullscreenOverlay true
