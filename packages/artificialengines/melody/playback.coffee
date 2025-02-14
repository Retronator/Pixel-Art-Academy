AMe = Artificial.Melody
AEc = Artificial.Echo

class AMe.Playback
  constructor: (@audioManager, @composition) ->
    @_currentSectionDepenency = new Tracker.Dependency
  
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
    
  currentSection: ->
    @_currentSectionDepenency.depend()
    @_currentSection
    
  connect: (node) ->
    sourceNode = @_getSourceNode()
    sourceNode.connect node
    
  disconnect: ->
    @_output?.disconnect()

  start: ->
    @stop()
    
    @_context = @audioManager.context()

    output = @_getSourceNode()
    
    @_currentSection = @composition.initialSection
    @_currentSectionStartTime = @_context.currentTime
    @_currentSectionHandle = @_currentSection.schedule @_currentSectionStartTime, output
    
    @_scheduleNextSection @_getAutomaticNextSection @composition.initialSection
    
    @_currentSectionDepenency.changed()
    
    # Listen for transitions.
    @_transitionsAutorun = Tracker.autorun =>
      return unless @ready()
      
      currentSection = @currentSection()
      activeTransition = false

      for transition in currentSection.transitions
        if transition.condition?()
          console.log "Transition condition met", transition if AMe.debug
          activeTransition = transition
          
          # Note: It's important we don't break here and continue going over all the transitions since it's not the
          # first that passes, but the last that passes to be the one we transition to. That way we can have more simple
          # conditions at the start and more complex ones later that override the simple ones.
          
      if activeTransition
        @_scheduleNextSection activeTransition.nextSection
      
      else
        console.log "No transition condition was met, continuing to automatic next section." if AMe.debug
        @_scheduleNextSection @_getAutomaticNextSection currentSection
      
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
    
    @_currentSection = null
    @_nextSection = null
    
  _scheduleNextSection: (section) ->
    return if section is @_nextSection
    
    console.log "Scheduling next section", section if AMe.debug
    
    @_nextSectionHandle?.stop()
    
    @_nextSection = section
    @_nextSectionStartTime = @_currentSectionStartTime + @_currentSection.duration
    output = @_getSourceNode()
    
    @_nextSectionHandle = @_nextSection.schedule @_nextSectionStartTime, output
  
    # Schedule handling of the next section for the case when no transitions get triggered.
    @_scheduleNextSectionHandling()
  
  _scheduleNextSectionHandling: ->
    return unless @_nextSectionStartTime
    @_clearNextSectionHandling()
    
    timeTillRepetition = @_nextSectionStartTime - @_context.currentTime
    console.log "Attempting next section handling in #{timeTillRepetition}s." if AMe.debug
    
    @_scheduleNextSectionTimeout = Meteor.setTimeout =>
      console.log "New section started", @_context.currentTime, @_nextSection if AMe.debug
  
      previousSection = @_currentSection
      @_currentSection = @_nextSection
      @_currentSectionStartTime = @_nextSectionStartTime
      @_currentSectionHandle = @_nextSectionHandle
      
      @_nextSection = null
      @_nextSectionHandle = null

      @_scheduleNextSection @_getAutomaticNextSection @_currentSection
      
      @_currentSectionDepenency.changed() unless previousSection is @_currentSection
    ,
      timeTillRepetition * 1000
    
  _getAutomaticNextSection: (section) ->
    # Repeat the section or follow any automatic transitions.
    nextSection = section
    
    for transition in section.transitions when not transition.condition
      nextSection = transition.nextSection
      
    nextSection
    
  _clearNextSectionHandling: ->
    console.log "Canceling next section handling." if AMe.debug
    Meteor.clearTimeout @_scheduleNextSectionTimeout
