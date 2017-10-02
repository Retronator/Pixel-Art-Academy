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

    # Start at the default player timeline.
    unless @playerTimelineId()
      @playerTimelineId PixelArtAcademy.TimelineIds.DareToDream

    @currentTimelineId = new ComputedField =>
      console.log "Recomputing current timeline." if LOI.debug

      # Player's timeline is always read from the state.
      if LOI.characterId()
        return unless gameState = @gameState()

        # For characters, start in the present.
        unless gameState.currentTimelineId
          gameState.currentTimelineId = PixelArtAcademy.TimelineIds.Present
          @gameState.updated()
        
        gameState.currentTimelineId

      else
        # Player's timeline is stored in local storage.
        @playerTimelineId()
    ,
      true

  setTimelineId: (timelineEntity) ->
    timelineId = _.thingId timelineEntity

    # Set the player timeline if we're not playing as a character.
    @playerTimelineId timelineId unless LOI.characterId()

    # Save current timeline to state. It controls the character's timeline, but for
    # players we don't really use it except until the next time we load the game.
    if state = @gameState()
      state.currentTimelineId = timelineId
      @gameState.updated()

  goToTimeline: (timelineEntity) ->
    @setTimelineId timelineEntity
