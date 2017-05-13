AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeTimeline: ->
    # We store player's current timeline locally so that multiple people
    # can use the same user account and walk around independently.
    @currentTimelineId = new ReactiveField null
    Artificial.Mummification.PersistentStorage.persist
      storageKey: 'LandsOfIllusions.Adventure.currentTimelineId'
      field: @currentTimelineId
      tracker: @

    # React to timeline changes.
    @autorun (computation) =>
      currentTimelineId = @currentTimelineId()

      Tracker.nonreactive =>
        # If we don't have a timeline set, start at the default timeline.
        unless currentTimelineId
          currentTimelineId = PixelArtAcademy.TimelineIds.DareToDream
          @currentTimelineId currentTimelineId

        # Save current timeline to state. We don't really use it except until the next time we load the game.
        if state = @gameState()
          state.currentTimelineId = currentTimelineId
          @gameState.updated()

  goToTimeline: (timelineEntity) ->
    # Change timeline.
    @currentTimelineId _.thingId timelineEntity
