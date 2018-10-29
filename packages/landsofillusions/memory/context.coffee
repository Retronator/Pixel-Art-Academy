AB = Artificial.Babel
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class LOI.Memory.Context extends LOI.Adventure.Context
  @id: -> 'LandsOfIllusions.Memory.Context'
  @fullName: -> 'memory'

  @classes = []

  @initialize: ->
    super arguments...
    
    # Subscribe to context's namespace.
    if Meteor.isClient
      namespace = @id()
      @translationHandle = AB.subscribeNamespace namespace

    @classes.push @
    
  @initialize()

  @findContextClassForMemory: (memory) ->
    # Here we query all inherited classes (except Conversation,
    # which is a fallback) to get one that creates the context.
    customContextClasses = _.without LOI.Memory.Context.classes, LOI.Memory.Context, LOI.Memory.Contexts.Conversation

    return contextClass for contextClass in customContextClasses when contextClass.canHandleMemory memory
       
    # Fallback to a plain conversation memory context if none other can handle it.
    LOI.Memory.Contexts.Conversation
        
  @createContext: (memory) ->
    # Here we query all inherited classes (except Conversation,
    # which is a fallback) to get one that creates the context.
    customContextClasses = _.without LOI.Memory.Context.classes, LOI.Memory.Context, LOI.Memory.Contexts.Conversation

    for contextClass in customContextClasses
      if context = contextClass.tryCreateContext memory
        # We've reached the correct context class.
        break

    # Fallback to a plain conversation memory context if none other can handle it.
    unless context
      context = LOI.Memory.Contexts.Conversation.tryCreateContext memory

    context

  # Override to say if the memory document matches this context.
  @canHandleMemory: (memory) -> false

  # Override to create a context if the memory document matches this context.
  @tryCreateContext: (memory) ->
    # Create the context for this entry.
    context = new @

    # Start in the provided memory.
    context.displayMemory memory._id

    # Return the context.
    context
    
  # Override to provide an intro describing what is going on at the start of this memory.
  # By default, it outputs the intro description to the narrative.
  @createIntroDescriptionScript: (memory, people, nextNode, nodeOptions) -> null

  @_createDescriptionScript: (people, description, nextNode, nodeOptions) ->
    return unless description

    # Format people into the description.
    description = LOI.Character.Agents.formatText description, 'people', people

    options = _.extend {}, nodeOptions,
      line: description
      next: nextNode

    new Nodes.NarrativeLine options
    
  @getPeopleForMemory: (memory) ->
    # Add all characters that have actions in the memory.
    characterIds = _.uniq _.map memory.actions, (action) => action.character._id

    LOI.Character.getAgent characterId for characterId in characterIds

  constructor: ->
    super arguments...

    @memoryId = new ReactiveField null
  
  onCreated: ->
    super arguments...

    # Subscribe to all the memories.
    @autorun (computation) =>
      return unless @isCreated()
      return unless memoryIds = @memoryIds()

      LOI.Memory.forIds.subscribe @, memoryIds

    @memories = new ComputedField =>
      return unless memoryIds = @memoryIds()

      # Get memories that happened at the same situation.
      LOI.Memory.documents.fetch
        _id: $in: memoryIds
        timelineId: LOI.adventure.currentTimelineId()
        locationId: LOI.adventure.currentLocationId()
    ,
      true

    @memory = new ComputedField =>
      LOI.Memory.documents.findOne @memoryId()
    ,
      true

    # Generate all people that need to be present in this context.
    @people = new ComputedField =>
      # Get the first person of every memory.
      memories = @memories() or []

      # Get only the latest memory per person.
      memories = _.reverse _.sortBy memories, (memory) => memory.endTime
      memories = _.uniqBy memories, (memory) => memory.actions?[0]?.character._id
      _.pull memories, undefined

      # Go over all memories but make sure actions are present
      # since they will be updated with delay as a recursive field.
      people = for memory in memories when memory.actions?[0]
        action = memory.actions[0].cast()
        characterId = action.character._id

        # Convert the character into a person, performing the starting action.
        person = new LOI.Character.Person characterId
        person.setAction action

        person

      if memory = @memory()
        # Add all characters that have actions in the currently focused memory.
        characterIds = _.uniq _.map memory.actions, (action) => action.character._id

        for characterId in characterIds
          characterPresent = _.find people, (person) => person._id is characterId

          # Create a person without an action set.
          people.push new LOI.Character.Person characterId unless characterPresent

      people
    ,
      true

    # Create the script based on memory actions.
    @autorun (computation) =>
      # Wait for everything to be loaded.
      return unless @isCreated()
      return unless memory = @memory()
      return unless people = @people()
      return unless _.every _.map people, (person) => person?.ready()
      return unless progress = LOI.Memory.Progress.documents.findOne 'character._id': LOI.characterId()

      actions = memory.actions

      lastNode = null

      # React to memory changes.
      unless memory._id is @_currentMemoryId
        # Display the conversation into a clear narrative.
        LOI.adventure.interface.narrative.clear scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.None

        # Reset last display time so we start at the beginning of the actions.
        @lastDisplayedActionTime = null

        # Save new memory ID.
        @_currentMemoryId = memory._id

      # We only need to create a script for the actions we haven't displayed yet.
      if @lastDisplayedActionTime
        actions = _.filter actions, (action) => action.time.getTime() > @lastDisplayedActionTime

      # Do we have anything we haven't displayed yet even?
      return unless actions.length

      @lastDisplayedActionTime = _.last(actions).time.getTime()

      # See if the player already observed some of the actions before.
      observedTime = progress.getTimeForMemoryId memory._id

      for action in actions by -1
        actionTime = action.time
        observed = actionTime.getTime() <= observedTime?.getTime()

        # Outside of memories, dialogue always write it immediately in full.
        immediate = if LOI.adventure.currentMemory() then observed else true

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
        actionEndScript = action.createEndScript person, lastNode, immediate: immediate
        lastNode = actionEndScript if actionEndScript

        actionStartScript = action.createStartScript person, lastNode, immediate: immediate
        lastNode = actionStartScript if actionStartScript

      LOI.adventure.director.startNode lastNode

  memoryIds: -> # Override to provide available memories to choose between.

  createNewMemory: ->
    memoryId = Random.id()
    timelineId = LOI.adventure.currentTimelineId()
    locationId = LOI.adventure.currentLocationId()

    LOI.Memory.insert memoryId, timelineId, locationId

    # Return the memory ID so the caller can add actions to it.
    memoryId
    
  displayNewMemory: ->
    memoryId = @createNewMemory()
    @displayMemory memoryId

    # Return the memory ID so the caller can add actions to it.
    memoryId

  displayMemory: (memoryId) ->
    # Allow reshowing the same memory by temporarily cleaning out memory.
    @memoryId null if @_currentMemoryId is memoryId

    # Reset which memory we were showing to restart script generation.
    @_currentMemoryId = null

    # Set the new memory ID which will update the people.
    @memoryId memoryId

  overrideThings: ->
    return [] unless @isCreated()

    @people()

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

  # Override to listen to commands while this is the advertised context.
  onCommandWhileAdvertised: (commandResponse) ->

  onCommand: (commandResponse) ->
    super arguments...

    # We allow to exit memories.
    return unless LOI.adventure.currentMemoryId()

    exitAction = => LOI.adventure.exitMemory()

    commandResponse.onExactPhrase
      form: [Vocabulary.Keys.Directions.Back]
      # We want to override the back command that just exits the context.
      priority: 1
      action: exitAction

    commandResponse.onExactPhrase
      form: [Vocabulary.Keys.Directions.Out]
      action: exitAction

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.ExitLocation, @avatars.memory]
      action: exitAction
