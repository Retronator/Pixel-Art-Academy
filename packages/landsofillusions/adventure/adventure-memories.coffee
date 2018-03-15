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

    # Start memory context after we've reached the new location.
    @autorun (computation) =>
      return unless memory = @currentMemory()
      return unless memory.locationId is @currentLocationId()
      computation.stop()

      # Give the interface time to react to location change and clear the context, before we set the new one.
      Meteor.setTimeout => @enterContext LOI.Memory.Context

  exitMemory: ->
    # End memory context.
    @exitContext()

    @currentMemoryId null
