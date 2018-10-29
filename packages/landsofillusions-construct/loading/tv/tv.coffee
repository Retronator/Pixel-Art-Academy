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
    super arguments...

  onCreated: ->
    super arguments...

    @screens =
      mainMenu: new @constructor.MainMenu @
      newLink: new @constructor.NewLink @

    @switchToScreen @screens.mainMenu

    @_fade = new ReactiveField false

    # Subscribe to all character part templates and the sprites that they use.
    types = LOI.Character.Part.Types.Avatar.allPartTypeIds()

    LOI.Character.Part.Template.forTypes.subscribe @, types
    LOI.Assets.Sprite.forCharacterPartTemplatesOfTypes.subscribe @, types

  fadeVisibleClass: ->
    'visible' if @_fade()

  fadeDeactivate: (onComplete) ->
    @_fade true

    Meteor.setTimeout =>
      LOI.adventure.deactivateActiveItem()
      onComplete?()
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
