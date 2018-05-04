AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeTimeline: ->
    # We store player's current timeline locally so that multiple people
    # can use the same user account and walk around independently.
    @playerTimelineId = new ReactiveField null

    Artificial.Mummification.PersistentStorage.persist
      storageKey: 'LandsOfIllusions.Adventure.currentTimelineId'
      field: @playerTimelineId
      tracker: @
      consentField: LOI.settings.persistGameState.allowed

    # Start at the default player timeline.
    unless @playerTimelineId()
      @playerTimelineId @startingPoint()?.timelineId

    @currentTimelineId = new ComputedField =>
      console.log "Recomputing current timeline." if LOI.debug

      # Memory overrides other timelines.
      return LOI.TimelineIds.Memory if @currentMemory()

      if LOI.characterId() or not LOI.settings.persistGameState.allowed()
        # Player's timeline is always read from the state. Also use when storing game state is not allowed.
        return unless gameState = @gameState()

        # For characters, start in the present.
        unless gameState.currentTimelineId
          gameState.currentTimelineId = if LOI.characterId() then LOI.TimelineIds.Present else @startingPoint()?.timelineId

          # Only signal the change if we actually changed it (starting point might not provide a timeline).
          @gameState.updated() if gameState.currentTimelineId

        timelineId = gameState.currentTimelineId

      else
        # Player's timeline is stored in local storage.
        timelineId = @playerTimelineId()

      console.log "Current timeline ID is", timelineId if LOI.debug or LOI.Adventure.debugLocation

      timelineId
    ,
      true

  setTimelineId: (timelineEntity) ->
    timelineId = _.thingId timelineEntity

    # Set the player timeline if we're not playing as a character.
    @playerTimelineId timelineId unless LOI.characterId()

    # Save current timeline to state.
    if state = @gameState()
      state.currentTimelineId = timelineId
      @gameState.updated()

  goToTimeline: (timelineEntity) ->
    @setTimelineId timelineEntity
