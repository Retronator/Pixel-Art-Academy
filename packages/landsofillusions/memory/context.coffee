LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class LOI.Memory.Context extends LOI.Adventure.Context
  @id: -> 'LandsOfIllusions.Memory.Context'
  @fullName: -> 'memory'

  @classes = []

  @initialize: ->
    super

    @classes.push @
    
  @initialize()
    
  # Override to tell if a memory is from this context.
  @isOwnMemory: (memory) -> false
    
  constructor: (@initialMemoryId) ->
    super
  
  onCreated: ->
    super

    @autorun (computation) =>
      return unless characterId = LOI.characterId()

      # Subscribe to character's memory progress.
      LOI.Memory.Progress.forCharacter.subscribe characterId

    @memoryId = new ReactiveField @initialMemoryId

    @memory = new ComputedField =>
      return unless memoryId = @memoryId()

      # Subscribe and retrieve the memory.
      LOI.Memory.forId.subscribe memoryId
      LOI.Memory.documents.findOne memoryId

    @characters = new ComputedField =>
      return unless memory = @memory()

      # Get all present character IDs.
      characterIds = _.uniq _.map memory.actions, (action) => action.character._id

      # Convert them into character instances.
      LOI.Character.getInstance characterId for characterId in characterIds

    # Create the script based on memory actions.
    @autorun (computation) =>
      # Wait for memory to be loaded.
      return unless memory = LOI.adventure.currentMemory()
      return unless characters = @characters()
      return unless _.every _.map characters, (character) => character.ready()
      return unless progress = LOI.Memory.Progress.documents.findOne 'character._id': LOI.characterId()

      lastNode = null

      actions = _.sortBy memory.actions, (action) => action.time.getTime()

      # We only need to create a script for the actions we haven't displayed yet.
      if @lastDisplayedActionTime
        actions = _.filter actions, (action) => action.time.getTime() > @lastDisplayedActionTime

      # Do we have anything we haven't displayed yet even?
      return unless actions.length

      @lastDisplayedActionTime = _.last(actions).time.getTime()

      # See if the player already observed some of the actions before.
      observedTime = progress.getTimeForMemoryId memory._id

      for action in actions by -1
        # After we've seen the line, report it to the server with a callback node.
        actionTime = action.time
        observed = actionTime.getTime() <= observedTime?.getTime()

        unless observed
          updateObservedTimeNode = do (actionTime) =>
            new Nodes.Callback
              next: lastNode
              callback: (complete) =>
                complete()

                LOI.Memory.Progress.updateProgress LOI.characterId(), memory._id, actionTime

        # Show the say action.
        lastNode = new Nodes.DialogueLine
          line: action.content.say.text
          actor: _.find characters, (character) => character._id is action.character._id
          next: if observed then lastNode else updateObservedTimeNode
          # Immediately show already observed actions.
          immediate: observed

      LOI.adventure.director.startNode lastNode

  overrideThings: ->
    # Memory context shows only characters in involved in the actions.
    return [] unless @isCreated()

    @characters()

  overrideExits: -> {}

  deactivate: ->
    # If we're in a memory, deactivate the memory itself which will also deactivate the context.
    if LOI.adventure.currentMemoryId()
      LOI.adventure.exitMemory()

    else
      LOI.adventure.exitContext()
      
  # Listener

  @avatars: ->
    # We need to provide the memory avatar since this class could be
    # inherited from and options.parent will not have the correct avatar.
    memory: LOI.Memory.Context

  onCommand: (commandResponse) ->
    context = @options.parent

    return unless LOI.adventure.currentMemoryId()

    exitAction = => LOI.adventure.exitMemory()

    commandResponse.onExactPhrase
      form: [Vocabulary.Keys.Directions.Back]
      action: exitAction

    commandResponse.onExactPhrase
      form: [Vocabulary.Keys.Directions.Out]
      action: exitAction

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.ExitLocation, @avatars.memory]
      action: exitAction

    sayAction = (likelyAction) =>
      # Remove text from narrative since it will be displayed from the script.
      LOI.adventure.interface.narrative.removeLastCommand()

      message = _.trim _.last(likelyAction.translatedForm), '"'

      unless memoryId = context.memoryId()
        # We don't have a memory yet, first create it.
        memoryId = Random.id()
        LOI.Memory.insert memoryId, LOI.currentLocationId()

      # Add the Say action.
      content =
        say:
          text: message

      LOI.Memory.Action.insert memoryId, LOI.characterId(), LOI.Memory.Action.Types.Say, content

    # Create a quoted phrase to catch anything included with the say command.
    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Say, '""']
      action: sayAction

    # Allow also just quotes.
    commandResponse.onPhrase
      form: ['""']
      action: sayAction
