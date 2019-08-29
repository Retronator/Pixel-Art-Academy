AM = Artificial.Mummification
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

class LOI.Memory.Flashback extends LOI.Adventure.Global
  @id: -> 'LandsOfIllusions.Memory.Flashback'

  @scenes: -> [
    @Scene
  ]

  @initialize()
  
  class @Scene extends LOI.Adventure.Scene
    @id: -> 'LandsOfIllusions.Memory.Flashback.Scene'

    # Activate this scene on the current location/timeline. It can't be null because that would apply it to all
    # locations simultaneously, including things like inventory and apps.
    location: -> LOI.adventure.currentLocationId()
    timelineId: -> LOI.adventure.currentTimelineId()

    @initialize()
  
    constructor: ->
      super arguments...

      @memoryId = new ReactiveField null
      @memoryPlayed = new ReactiveField false

      # Subscribe to get memory data.
      @_memorySubscriptionAutorun = Tracker.autorun (computation) =>
        return unless memoryId = @memoryId()
        LOI.Memory.forId.subscribe memoryId

      @memory = new ComputedField =>
        LOI.Memory.documents.findOne @memoryId()

      # Run flashback when getting a new memory.
      @_memoryAutorun = Tracker.autorun (computation) =>
        return if @memoryPlayed()
        return unless memory = @memory()

        people = @people()
        return unless people.length

        # Don't run if we're inside a context.
        return if LOI.adventure.currentContext()

        # Reset actions of involved people.
        person.setAction null for person in people

        # Only react to memory changes.
        Tracker.nonreactive =>
          # Wait 3 seconds before starting to play.
          Meteor.setTimeout =>
            # Make sure we didn't enter a context while we were waiting.
            return if LOI.adventure.currentContext()

            actions = _.reverse memory.actions

            # Show only up to 5 last actions.
            for action in actions[...5]
              # Cast into correct type.
              action = action.cast()

              person = _.find people, (person) => person._id is action.character._id

              # Start and end the action (in reverse order).
              actionEndScript = action.createEndScript person, lastNode, background: true
              lastNode = actionEndScript if actionEndScript
      
              actionStartScript = action.createStartScript person, lastNode, background: true
              lastNode = actionStartScript if actionStartScript

              # Show what the person is doing when this action runs.
              lastNode = do (action, person) =>
                new Nodes.Callback
                  next: lastNode
                  callback: (complete) =>
                    complete()

                    person.setAction action

            # Add intro into this memory.
            contextClass = LOI.Memory.Context.findContextClassForMemory memory

            actionStartScript = contextClass.createIntroDescriptionScript memory, people, lastNode, background: true
            lastNode = actionStartScript if actionStartScript

            if characterId = LOI.characterId()
              # Mark this memory as discovered so we don't flashback to it again.
              lastNode = new Nodes.Callback
                next: lastNode
                callback: (complete) =>
                  complete()
  
                  LOI.Memory.Progress.discoverMemory characterId, memory._id

            # Mark that we've played this memory.
            @memoryPlayed true

            # Mark it in ephemeral state as well so we don't play it again when we return.
            fieldName = "#{memory.timelineId}-#{memory.locationId}"
            flashbackState = @flashbacksState fieldName
            flashbackState.playStart = Date.now()
            @flashbacksState fieldName, flashbackState

            # Advertise flashback's context.
            context = LOI.Memory.Context.createContext memory
            LOI.adventure.advertiseContext context

            LOI.adventure.director.startBackgroundNode lastNode
          ,
            3000

      # Generate all people that need to be present for this flashback.
      @people = new ComputedField =>
        return [] unless memory = @memory()

        contextClass = LOI.Memory.Context.findContextClassForMemory memory
        contextClass.getPeopleForMemory memory
      ,
        true

      # We store selected flashbacks to session storage.
      @flashbacksState = new LOI.EphemeralStateObject

      @_flashbacksStateChangeAutorun = AM.PersistentStorage.persist
        storageKey: "#{@id()}.flashbacksState"
        storage: sessionStorage
        field: @flashbacksState.field()

      # Listen to location changes.
      @_locationAutorun = Tracker.autorun (computation) =>
        return unless timelineId = LOI.adventure.currentTimelineId()
        return unless location = LOI.adventure.currentLocation()

        locationId = location.id()
        locationIsPrivate = location.isPrivate()

        if locationIsPrivate
          # Don't show flashbacks at private locations.
          flashbackState = null

        else
          # See if we've already shown a flashback at this location.
          fieldName = "#{timelineId}-#{locationId}"
          flashbackState = @flashbacksState fieldName

        @memoryId flashbackState?.memoryId or null
        @memoryPlayed flashbackState?.playStart? or false

        return if locationIsPrivate

        fetchNewMemory = _.some [
          # Fetch a memory if we haven't done it yet.
          not flashbackState
          # Also do it if it's been already played more than 10 minutes ago.
          Date.now() > flashbackState?.playStart + 10 * 60 * 1000
        ]

        return unless fetchNewMemory

        # We haven't figured a flashback yet, let's find one. Only show flashbacks within the last month.
        earliestTime = new Date Date.now() - 30 * 24 * 60 * 60 * 1000 # 30 days

        # Query the server for the last undiscovered memory at this location.
        LOI.Memory.getLastUndiscovered LOI.characterId(), timelineId, locationId, earliestTime, (error, memoryId) =>
          console.error error if error
          @memoryId memoryId

          # Store the flashback state.
          flashbackState = if memoryId then memoryId: memoryId else null
          @flashbacksState fieldName, flashbackState

    destroy: ->
      @_memorySubscriptionAutorun.stop()
      @memory.stop()
      @_memoryAutorun.stop()
      @flashbacksState.destroy()
      @_flashbacksStateChangeAutorun.stop()
      @_locationAutorun.stop()

    things: ->
      # Provide people that are part of this flashback.
      @people()
