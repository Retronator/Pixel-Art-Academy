LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class HQ.Items.OperatorLink extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.OperatorLink'

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

    @operator = new HQ.Actors.Operator

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

    @operator.destroy()

    @_charactersSubscription.stop()
    @activatedCharacters.stop()
    character.destroy() for character in @_characters if @_characters

  isVisible: -> false

  syncWithCharacter: (@_syncCharacter) ->
    listener = @listeners[0]

    ephemeralState = listener.script.ephemeralState()

    # Note that we can't store the full character into the state since it tries to be serialized.
    ephemeralState.characterId = @_syncCharacter.id
    ephemeralState.characterFullName = @_syncCharacter.avatar.fullName()

    listener.startScript label: 'CharacterSync'

  prepareDialogOptions: ->
    # Build all character selections. Last option of the selection is to not do anything.
    cancelNode = new Nodes.CommandLine
      line: "Nevermind"

    lastChoiceNode = new Nodes.Choice
      node: cancelNode

    # For each agent, create a choice node. Reverse the nodes so they appear in the same order.
    for character in @activatedCharacters()
      do (character) =>
        callbackNode = new Nodes.Callback
          callback: (complete) =>
            # Complete the callback since we'll start a new script from here.
            complete()

            # Start the sync script with this character as the active agent.
            @syncWithCharacter character

        dialogLineNode =
          new Nodes.DialogLine
            line: "I want to sync with #{character.avatar.fullName()}."
            next: callbackNode

        choiceNode = new Nodes.Choice
          node: dialogLineNode
          next: lastChoiceNode

        lastChoiceNode = choiceNode

    characterChoiceNode = lastChoiceNode

    # Find the last of this script's questions.
    listener = @listeners[0]

    for node in listener.script.nodes
      if node.next is listener.script.startNode.labels.CharactersPlaceholder or node.next is @_lastCharacterChoiceNode
        node.next = characterChoiceNode

    # Save which node is in the location of the placeholder.
    @_lastCharacterChoiceNode = characterChoiceNode

  # Script

  initializeScript: ->
    @setThings
      operator: @options.parent.operator

    @setCallbacks
      Exit: (complete) =>
        LOI.adventure.goToLocation HQ.LandsOfIllusions.Room
        LOI.adventure.goToTimeline PAA.TimelineIds.RealLife
        complete()

      Construct: (complete) =>
        LOI.adventure.goToLocation LOI.Construct.Loading
        LOI.adventure.goToTimeline PAA.TimelineIds.Construct
        complete()

      CharacterSync: (complete) =>
        ephemeralState = @ephemeralState()
        console.log "DODODODO", LOI.Character.documents.findOne ephemeralState.characterId

        complete()

  # Listener

  onCommand: (commandResponse) ->
    operatorLink = @options.parent
    operator = operatorLink.operator

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, [operatorLink.avatar, operator.avatar]]
      priority: -1
      action: =>
        operatorLink.prepareDialogOptions()
        @startScript()
