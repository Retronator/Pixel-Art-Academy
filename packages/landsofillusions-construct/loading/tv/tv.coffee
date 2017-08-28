LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Construct.Loading.TV extends LOI.Components.Computer
  @id: -> 'LandsOfIllusions.Construct.Loading.TV'
  @url: -> 'character-selection'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "Television"
  @shortName: -> "TV"
  @description: ->
    "
      It's an old school television with a remote display. There are people's portraits displayed on the screen.
    "

  @initialize()

  constructor: ->
    super

  onCreated: ->
    super

    @screens =
      mainMenu: new @constructor.MainMenu @

    @switchToScreen @screens.mainMenu

    @_fade = new ReactiveField false

  fadeVisibleClass: ->
    'visible' if @_fade()

  fadeDeactivate: (onComplete) ->
    @_fade true

    Meteor.setTimeout =>
      onComplete?()
      @deactivate()
    ,
      4000

  onDeactivate: (finishedDeactivatingCallback) ->
    # Deactivate immediately when fading to white.
    if @_fade()
      finishedDeactivatingCallback()
      return

    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  onCommand: (commandResponse) ->
    tv = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], tv.avatar]
      action: =>
        LOI.adventure.goToItem tv
