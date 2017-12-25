LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class HQ.Items.OperatorLink extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.OperatorLink'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "operator neural link"
  @shortName: -> "operator"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      This is a neural link with the operator who controls your immersion. It allows you to talk to them.
    "

  @defaultScriptUrl: -> 'retronator_retronator-hq/items/operatorlink/operatorlink.script'

  @initialize()

  constructor: ->
    super

    # Subscribe to user's activated characters.
    @_charactersSubscription = LOI.Character.activatedForCurrentUser.subscribe()

    @activatedCharacters = new ComputedField =>
      return unless user = Retronator.user()

      characterDocuments = _.filter user.characters, (character) =>
        character = LOI.Character.documents.findOne(character._id)

        character?.activated

      # Destroy previous character instances.
      character.destroy() for character in @_characters if @_characters

      @_characters = for characterDocument in characterDocuments
        new LOI.Character.Instance characterDocument._id

      @_characters

  destroy: ->
    super

    @_charactersSubscription.stop()
    @activatedCharacters.stop()
    character.destroy() for character in @_characters if @_characters

  onCreated: ->
    super

    @pluggedIn = new ReactiveField false
    @fastTransition = new ReactiveField false

  onActivate: (finishedActivatingCallback) ->
    Meteor.setTimeout =>
      finishedActivatingCallback()
    ,
      500

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  isVisible: -> false

  pluggedInClass: ->
    'pluggedIn' if @pluggedIn()

  fastTransitionClass: ->
    'fast-transition' if @fastTransition()

  enterConstruct: (complete) ->
    @pluggedIn true

    Meteor.setTimeout =>
      complete?()

      LOI.adventure.loadConstruct()

      @deactivate()
    ,
      4000

  syncWithCharacter: (@_syncCharacter) ->
    listener = @listeners[0]

    ephemeralState = listener.script.ephemeralState()

    # Note that we can't store the full character into the state since it tries to be serialized.
    ephemeralState.characterId = @_syncCharacter.id()
    ephemeralState.characterFullName = @_syncCharacter.avatar.fullName()

    listener.startScript label: 'CharacterSync'

  prepareDialogOptions: ->
    listener = @listeners[0]

    # Build all character selections. Last option of the selection is to not do anything and deactivate SYNC.
    cancelNode = new Nodes.CommandLine
      line: "Nevermind"
      next: new Nodes.Callback
        callback: (complete) =>
          complete()

          listener.startScript label: 'DeactivateSync'

    lastChoiceNode = new Nodes.Choice
      node: cancelNode

    currentCharacter = LOI.character()

    # For each agent, create a choice node. Reverse the nodes so they appear in the same order.
    for character in @activatedCharacters() when character.id() isnt currentCharacter?.id()
      do (character) =>
        callbackNode = new Nodes.Callback
          callback: (complete) =>
            # Complete the callback since we'll start a new script from here.
            complete()

            # Start the sync script with this character as the active agent.
            @syncWithCharacter character

        dialogueLineNode =
          new Nodes.DialogueLine
            line: "I want to sync with #{character.avatar.fullName()}."
            next: callbackNode

        choiceNode = new Nodes.Choice
          node: dialogueLineNode
          next: lastChoiceNode

        lastChoiceNode = choiceNode

    characterChoiceNode = lastChoiceNode

    for node in listener.script.nodes
      if node.next is listener.script.startNode.labels.CharactersPlaceholder or node.next is @_lastCharacterChoiceNode
        node.next = characterChoiceNode

    # Save which node is in the location of the placeholder.
    @_lastCharacterChoiceNode = characterChoiceNode

  start: ->
    @_start true

  startWithoutIntro: ->
    @_start false

  _start: (intro) ->
    @prepareDialogOptions()

    listener = @listeners[0]

    # Check if the player is already immersed.
    if LOI.adventure.currentTimelineId() is PAA.TimelineIds.Construct or LOI.characterId()
      # Yeah, skip straight to the operator dialog.
      label = 'ImmersedStart'

    else if intro
      # No, show the full intro.
      label = 'Start'

    else
      # No, and the intro was already provided by the caller.
      label = 'ActivateSync'

    listener.startScript {label}

  # Script

  initializeScript: ->
    operatorLink = @options.parent
    operator = @options.listener.avatars.operator

    @setThings
      operator: operator

    @setCallbacks
      ActivateSync: (complete) =>
        operatorLink.activate()
        complete()

      DeactivateSync: (complete) =>
        operatorLink.deactivate()
        complete()

      Construct: (complete) =>
        operatorLink.enterConstruct complete

      Exit: (complete) =>
        operatorLink.pluggedIn true
        operatorLink.fastTransition true

        Meteor.setTimeout =>
          complete()

          # See if we're exiting from character's world of from the construct.
          if LOI.characterId()
            LOI.adventure.unloadCharacter()

          else
            LOI.adventure.unloadConstruct()

          operatorLink.pluggedIn false
          operatorLink.deactivate()
        ,
          500

      CharacterSync: (complete) =>
        operatorLink.pluggedIn true

        Meteor.setTimeout =>
          complete()

          LOI.adventure.loadCharacter @ephemeralState().characterId

          operatorLink.deactivate()
        ,
          4000

  # Listener

  @avatars: ->
    operator: HQ.Actors.Operator

  onCommand: (commandResponse) ->
    operatorLink = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, [operatorLink.avatar, @avatars.operator]]
      priority: -1
      action: => operatorLink.start()

    if LOI.adventure.currentLocationId() is LOI.Construct.Loading.id()
      commandResponse.onExactPhrase
        form: [Vocabulary.Keys.Directions.Out]
        action: => @startScript label: 'Exit'
