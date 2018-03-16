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
      Meteor.setTimeout =>
        # Find which context class this memory belongs to.
        for contextClass in LOI.Memory.Context.classes
          if contextClass.isOwnMemory memory
            # We've reached the correct context class.
            break

        # Fallback to plain memory context if none other can handle it (usually indicates a direct conversation).
        contextClass = LOI.Memory.Context unless contextClass
        
        # Create the context based on the memory.
        context = new contextClass memoryId

        @enterContext context

  exitMemory: ->
    # Stop all scripts and reset the interface to clean up current interactions.
    @director.stopAllScripts()
    @interface.reset()
    @interface.stopIntro()

    # End memory context.
    @exitContext()

    @currentMemoryId null
