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
    
  constructor: (@memoryId) ->
    super
  
  onCreated: ->
    super

    LOI.Memory.forId.subscribe @, @memoryId

    # Subscribe to character's memory progress.
    @autorun (computation) =>
      return unless characterId = LOI.characterId()

      LOI.Memory.Progress.forCharacter.subscribe characterId

    @memory = new ComputedField =>
      LOI.Memory.documents.findOne @memoryId

    # Generate all characters that need to be present when in this memory.
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
    # When inside a memory, context shows only characters in involved in the actions.
    return unless LOI.adventure.currentMemoryId()
    return [] unless @isCreated()

    @characters()

  overrideExits: ->
    # Only remove exits when in a memory.
    return unless LOI.adventure.currentMemoryId()

    {}

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
