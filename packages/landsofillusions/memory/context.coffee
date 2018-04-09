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

    @memory = new ComputedField =>
      LOI.Memory.documents.findOne @memoryId

    # Generate all characters that need to be present when in this memory.
    @people = new ComputedField =>
      return unless memory = @memory()

      # Get all present character IDs.
      characterIds = _.uniq _.map memory.actions, (action) => action.character._id

      # Convert them into people.
      LOI.adventure.getCurrentPerson characterId for characterId in characterIds

    # Create the script based on memory actions.
    @autorun (computation) =>
      # Wait for everything to be loaded.
      return unless memory = @memory()
      return unless people = @people()
      return unless _.every _.map people, (person) => person?.ready()
      return unless progress = LOI.Memory.Progress.documents.findOne 'character._id': LOI.characterId()

      # We only do this once, since after this, people will be reporting their actions on their own.
      computation.stop()

      actions = _.sortBy memory.actions, (action) => action.time.getTime()

      # Cast actions and inject the memoryId since it's not present as one of the reverse fields.
      actions = for action in actions
        action = action.cast()
        action.memory = _id: @memoryId
        action

      lastNode = null

      # See if the player already observed some of the actions before.
      observedTime = progress.getTimeForMemoryId memory._id

      for action in actions by -1
        actionTime = action.time
        observed = actionTime.getTime() <= observedTime?.getTime()
        person = _.find people, (person) => person._id is action.character._id

        # After we've seen the line, report it to the server with a callback node.
        unless observed
          lastNode = do (actionTime) =>
            new Nodes.Callback
              next: lastNode
              callback: (complete) =>
                complete()

                LOI.Memory.Progress.updateProgress LOI.characterId(), memory._id, actionTime

        # Start and end the action (in reverse order).
        actionEndScript = action.createEndScript person, lastNode, immediate: observed
        lastNode = actionEndScript if actionEndScript

        actionStartScript = action.createStartScript person, lastNode, immediate: observed
        lastNode = actionStartScript if actionStartScript

      # Display the current conversation into a clear narrative.
      LOI.adventure.interface.narrative.clear()
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
