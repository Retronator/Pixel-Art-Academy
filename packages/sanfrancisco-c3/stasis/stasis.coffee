LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class C3.Stasis extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.C3.Stasis'
  @url: -> 'c3/stasis'
  @region: -> C3

  @version: -> '0.0.1'

  @fullName: -> "Cyborg Construction Center Stasis Chamber"
  @shortName: -> "Stasis"
  @description: ->
    "
      The Stasis Chamber holds a line of glass vats that stretch from floor to ceiling.
      Cybernetic bodies are suspended in them, the density of the liquid balanced exactly to have them floating without weight.
    "

  @defaultScriptUrl: -> 'retronator_sanfrancisco-c3/stasis/stasis.script'

  @initialize()

  constructor: ->
    super arguments...

    @characters = new ComputedField =>
      # Create a vat for each non-activated agent.
      return unless user = Retronator.user()

      characterDocuments = _.filter user.characters, (character) =>
        character = LOI.Character.documents.findOne(character._id)

        character?.behaviorApproved and not character?.activated

      # Destroy previous character instances.
      character.destroy() for character in @_characters if @_characters

      @_characters = for characterDocument in characterDocuments
        new LOI.Character.Instance characterDocument._id

      @_characters

    @_vats = new ComputedField =>
      return unless characters = @characters()
      vats = []

      for character in characters
        Tracker.nonreactive =>
          vats.push new @constructor.Vat {character}

      vats

  destroy: ->
    super arguments...

    @characters.stop()
    @_vats.stop()

    character.destroy() for character in @_characters if @_characters

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": C3.Behavior
    "#{Vocabulary.Keys.Directions.Southwest}": C3.Hallway
    "#{Vocabulary.Keys.Directions.East}": C3.RemoteControl

  things: ->
    things = [
      @constructor.EmptyVat
    ]

    if vats = @_vats()
      things = things.concat vats

    things.push @constructor.ControlPanel

    things

  syncWithCharacter: (@_syncCharacter) ->
    listener = @listeners[0]

    ephemeralState = listener.script.ephemeralState()

    # Note that we can't store the full character into the state since it tries to be serialized.
    ephemeralState.characterId = @_syncCharacter._id
    ephemeralState.characterFullName = @_syncCharacter.avatar.fullName()

    listener.startScript label: 'Sync'

  # Script

  initializeScript: ->
    stasis = @options.parent
    listener = @options.listener

    @setThings listener.avatars

    @setCallbacks
      AgentSelection: (complete) =>
        # Immediately complete since we'll start a new script made of custom nodes.
        complete()

        # Last option of the selection is to not do anything.
        cancelNode = new Nodes.CommandLine
          line: "Nevermind"

        lastChoiceNode = new Nodes.Choice
          node: cancelNode

        # For each agent, create a choice node. Reverse the nodes so they appear in the same order.
        for character in _.reverse stasis.characters()
          do (character) =>
            callbackNode = new Nodes.Callback
              callback: (complete) =>
                # Complete the callback since we'll start a new script from here.
                complete()

                # Start the sync script with this character as the active agent.
                stasis.syncWithCharacter character

            commandLineNode =
              new Nodes.CommandLine
                line: _.upperFirst character.avatar.fullName()
                next: callbackNode

            choiceNode = new Nodes.Choice
              node: commandLineNode
              next: lastChoiceNode

            lastChoiceNode = choiceNode

        agentChoiceNode = lastChoiceNode
        LOI.adventure.director.startNode agentChoiceNode
        
      AgentActivation: (complete) =>
        ephemeralState = @ephemeralState()
        LOI.Character.activate ephemeralState.characterId

        complete()

  # Listener

  @avatars: ->
    operator: Retronator.HQ.Actors.Operator

  onCommand: (commandResponse) ->
    if controlPanel = LOI.adventure.getCurrentThing C3.Stasis.ControlPanel
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Use, controlPanel.avatar]
        action: => @startScript label: 'UseControlPanel'
