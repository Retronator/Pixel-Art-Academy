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

    @memory = new ComputedField =>
      # Subscribe and retrieve the memory.
      LOI.Memory.forId.subscribe @memoryId
      LOI.Memory.documents.findOne @memoryId

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
      computation.stop()

      lastNode = null

      actions = _.sortBy memory.actions, (action) => action.time.getTime()

      for action in actions by -1
        lastNode = new Nodes.DialogueLine
          line: action.content.say.text
          actor: _.find characters, (character) => character._id is action.character._id
          next: lastNode

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

    # Create a quoted phrase to catch anything included with the say command.
    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Say, '""']
      action: (likelyAction) =>
        console.log "SAY", _.trim likelyAction.translatedForm[1], '"'
        true
