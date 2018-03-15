AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeMemories: ->
    @currentMemoryId = new ReactiveField null
    
    @currentMemory = new ComputedField =>
      return unless memoryId = @currentMemoryId()
      
      # Only characters can participate in memories.
      return unless LOI.characterId()

      # Subscribe and retrieve the memory.
      LOI.Memory.forId.subscribe memoryId
      LOI.Memory.documents.findOne memoryId

  enterMemory: (memoryOrMemoryId) ->
    memoryId = memoryOrMemoryId._id or memoryOrMemoryId
    @currentMemoryId memoryId

  exitMemory: ->
    @currentMemoryId null
