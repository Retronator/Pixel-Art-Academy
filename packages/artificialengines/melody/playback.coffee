AMe = Artificial.Melody
AEc = Artificial.Echo

class AMe.Playback
  constructor: (@audioManager, @composition) ->
  
  destroy: ->
    @stop()
    @_output?.disconnect()
    @_output = null
  
  ready: ->
    @audioManager.context()
  
  _getSourceNode: ->
    return @_output if @_output
    
    @_context = @audioManager.context()
    @_output = new GainNode @_context
    
  connect: (node) ->
    sourceNode = @_getSourceNode()
    sourceNode.connect node
    
  disconnect: ->
    @_output?.disconnect()

  start: ->
    @stop()
    
    @_context = @audioManager.context()

    output = @_getSourceNode()
    @_currentSectionDepenency = new Tracker.Dependency
    
    @currentSection = @composition.initialSection
    @_currentSectionStartTime = @_context.currentTime
    @_currentSectionHandle = @currentSection.schedule @_currentSectionStartTime, output
    
    @_scheduleNextSection @_getAutomaticNextSection @composition.initialSection
    
    # Listen for transitions.
    @_transitionsAutorun = Tracker.autorun =>
      return unless @ready()
      @_currentSectionDepenency.depend()

      for transition in @currentSection.transitions
        if transition.trigger?.value()
          console.log "Triggered transition", transition if AMe.debug
          @_scheduleNextSection transition.nextSection
          
    # Start/stop section handling when the context is resumed/suspended.
    @_sectionRepetitionAutorun = Tracker.autorun =>
      if @audioManager.running()
        console.log "Audio manager is running, schedule next section handling." if AMe.debug
        @_scheduleNextSectionHandling()
        
      else
        console.log "Audio manager is not running, cancel next section handling." if AMe.debug
        @_clearNextSectionHandling()
        
  stop: ->
    @_clearNextSectionHandling()

    @_currentSectionHandle?.stop()
    @_nextSectionHandle?.stop()

    @_transitionsAutorun?.stop()
    @_sectionRepetitionAutorun?.stop()
    
    @currentSection = null
    @nextSection = null
    
  _scheduleNextSection: (section) ->
    return if section is @nextSection
    
    console.log "Scheduling next section", section if AMe.debug
    
    @_nextSectionHandle?.stop()
    
    @nextSection = section
    @_nextSectionStartTime = @_currentSectionStartTime + @currentSection.duration
    output = @_getSourceNode()
    
    @_nextSectionHandle = @nextSection.schedule @_nextSectionStartTime, output
  
    # Schedule handling of the next section for the case when no transitions get triggered.
    @_scheduleNextSectionHandling()
  
  _scheduleNextSectionHandling: ->
    return unless @_nextSectionStartTime
    @_clearNextSectionHandling()
    
    timeTillRepetition = @_nextSectionStartTime - @_context.currentTime
    console.log "Attempting next section handling in #{timeTillRepetition}s." if AMe.debug
    
    @_scheduleNextSectionTimeout = Meteor.setTimeout =>
      console.log "New section started", @_context.currentTime, @nextSection if AMe.debug
  
      @currentSection = @nextSection
      @_currentSectionStartTime = @_nextSectionStartTime
      @_currentSectionHandle = @_nextSectionHandle
      
      @nextSection = null
      @_nextSectionHandle = null
      
      @_scheduleNextSection @_getAutomaticNextSection @currentSection
  
      @_currentSectionDepenency.changed()
    ,
      timeTillRepetition * 1000
    
  _getAutomaticNextSection: (section) ->
    # Repeat the section or follow any automatic transitions.
    nextSection = section
    
    for transition in section.transitions when not transition.trigger
      nextSection = transition.nextSection
      
    nextSection
    
  _clearNextSectionHandling: ->
    console.log "Canceling next section handling." if AMe.debug
    Meteor.clearTimeout @_scheduleNextSectionTimeout