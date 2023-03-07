AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeTimeline: ->
    @currentTimelineId = new ComputedField =>
      console.log "Recomputing current timeline." if LOI.debug

      # Memory overrides other timelines.
      if @currentMemory()
        timelineId = LOI.TimelineIds.Memory
        
      else
        timelineId = @gameState()?.currentTimelineId or @startingPoint()?.timelineId

      console.log "Current timeline ID is", timelineId if LOI.debug or LOI.Adventure.debugLocation

      timelineId
    ,
      true

  setTimelineId: (timelineEntity) ->
    timelineId = _.thingId timelineEntity

    # Save current timeline to state.
    if state = @gameState()
      state.currentTimelineId = timelineId
      @gameState.updated()

  goToTimeline: (timelineEntity) ->
    @setTimelineId timelineEntity
