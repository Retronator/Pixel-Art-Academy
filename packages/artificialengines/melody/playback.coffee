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
    
    @_scheduleTransition @_getAutomaticTransition @composition.initialSection
    
    @_currentSectionDepenency.changed()
    
    # Listen for transitions.
    @_transitionsAutorun = Tracker.autorun =>
      return unless @ready()
      
      currentSection = @currentSection()
      activeTransition = null

      for transition in currentSection.transitions
        if transition.condition?()
          console.log "Transition condition met", transition if AMe.debug
          activeTransition = transition
          
          # Note: It's important we don't break here and continue going over all the transitions since it's not the
          # first that passes, but the last that passes to be the one we transition to. That way we can have more simple
          # conditions at the start and more complex ones later that override the simple ones.
          
      if activeTransition
        @_scheduleTransition activeTransition
      
      else
        console.log "No transition condition was met, continuing to automatic transition." if AMe.debug
        @_scheduleTransition @_getAutomaticTransition currentSection
      
    # Start/stop section handling when the context is resumed/suspended.
    @_sectionRepetitionAutorun = Tracker.autorun =>
      if @audioManager.running()
        console.log "Audio manager is running, schedule transition handling." if AMe.debug
        @_scheduleTransitionHandling()
        
      else
        console.log "Audio manager is not running, cancel transition handling." if AMe.debug
        @_clearTransitionHandling()
        
  stop: ->
    @_clearTransitionHandling()

    @_currentSectionHandle?.stop()
    @_nextSectionHandle?.stop()

    @_transitionsAutorun?.stop()
    @_sectionRepetitionAutorun?.stop()
    
    @_currentSection = null
    @_nextSection = null
    @_nextTransition = null
    
  _scheduleTransition: (transition) ->
    return if transition and transition is @_nextTransition and transition.nextSection is @_nextSection
    
    @_nextTransition = transition

    # If no transition is provided, we repeat the current section.
    section = transition?.nextSection or @_currentSection
    
    return if section is @_nextSection
    
    console.log "Scheduling next section", section if AMe.debug
    
    @_nextSectionHandle?.stop()
    
    @_nextSection = section
    @_nextSectionStartTime = @_currentSectionStartTime + @_currentSection.duration
    output = @_getSourceNode()
    
    @_nextSectionHandle = @_nextSection.schedule @_nextSectionStartTime, output
  
    # Schedule handling of the next section for the case when no transitions get triggered.
    @_scheduleTransitionHandling()
  
  _scheduleTransitionHandling: ->
    return unless @_nextSectionStartTime
    @_clearTransitionHandling()
    
    timeTillNextSectionStart = @_nextSectionStartTime - @_context.currentTime
    console.log "Attempting next section handling in #{timeTillNextSectionStart}s." if AMe.debug
    
    @_scheduleTransitionTimeout = Meteor.setTimeout =>
      console.log "New section started", @_context.currentTime, @_nextSection if AMe.debug
  
      previousSection = @_currentSection
      @_currentSection = @_nextSection
      @_currentSectionStartTime = @_nextSectionStartTime
      @_currentSectionHandle = @_nextSectionHandle
      
      @_nextTransition?.transitionCount++
      
      @_nextTransition = null
      @_nextSection = null
      @_nextSectionHandle = null

      @_scheduleTransition @_getAutomaticTransition @_currentSection
      
      @_currentSectionDepenency.changed() unless previousSection is @_currentSection
    ,
      timeTillNextSectionStart * 1000
    
  _getAutomaticTransition: (section) ->
    # Follow any automatic transitions.
    automaticTransitions = (transition for transition in section.transitions when not transition.condition)
    
    return null unless automaticTransitions.length
    
    # Choose a random next section, among the ones with lowest play count.
    playCounts = (transition.transitionCount - transition.priority for transition in automaticTransitions)
    console.log "Choosing a random next section with prioritized play counts", playCounts if AMe.debug

    minPlayCount = _.min playCounts
    
    potentialTransitions = (transition for transition, index in automaticTransitions when playCounts[index] is minPlayCount)
    
    console.log "Potential sections with play count", minPlayCount, potentialTransitions if AMe.debug
    potentialTransitions[Math.floor(Math.random() * potentialTransitions.length)]
    
  _clearTransitionHandling: ->
    console.log "Canceling next section handling." if AMe.debug
    Meteor.clearTimeout @_scheduleTransitionTimeout
