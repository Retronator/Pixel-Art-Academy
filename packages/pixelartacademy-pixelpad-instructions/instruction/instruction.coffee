AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelPad.Systems.Instructions.Instruction extends AM.Component
  @_instructionClassesById = {}

  @getClassForId: (id) ->
    @_instructionClassesById[id]
    
  @getClasses: ->
    _.values @_instructionClassesById
    
  # Optional text related to this instruction.
  @message: -> null
  
  @activeConditions: -> throw new AE.NotImplementedException "Instructions must provide conditions for activation."
  
  @completedConditions: -> false # Override if this instruction can be completed (and not show up as active afterwards).
  @resetCompletedConditions: -> false # Override if the completed condition can be reset.
  
  @priority: -> 0
  
  @delayDuration: -> 0
  
  @activeDisplayState: ->
    # Override if you want the instruction to display closed.
    PAA.PixelPad.Systems.Instructions.DisplayState.Open
    
  @displaySide: ->
    # Override if the instruction doesn't appear at the bottom.
    PAA.PixelPad.Systems.Instructions.DisplaySide.Bottom

  @initialize: ->
    @register @id()
    
    # Store instruction class by ID.
    @_instructionClassesById[@id()] = @

    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create this instruction's translated names.
        translationNamespace = @id()
        
        for property in ['message']
          continue unless value = @[property]()
          AB.createTranslation translationNamespace, property, value
  
  @getAdventureInstanceForId: (instructionId) ->
    for episode in LOI.adventure.episodes()
      for chapter in episode.chapters
        for instruction in chapter.instructions
          return instruction if instruction.id() is instructionId

    # If instruction is not part of the storyline, it might be in the Study Guide.
    studyGuideGlobal = _.find LOI.adventure.globals, (global) => global instanceof PAA.StudyGuide.Global

    for instruction in studyGuideGlobal.instructions()
      return instruction if instruction.id() is instructionId

    console.warn "Unknown instruction requested.", instructionId
    null

  template: -> 'PixelArtAcademy.PixelPad.Systems.Instructions.Instruction'
  
  constructor: (@instructions) ->
    super arguments...
  
    @delayTime = new ReactiveField 0
    
    @completed = new ReactiveField false
  
    @_wasActive = false
  
    @_activeAutorun = Tracker.autorun (computation) =>
      active = @activeConditions()
      
      @onActivate() if active and not @_wasActive
      @onDeactivate() if @_wasActive and not active
      
      @_wasActive = active

    @_completedAutorun = Tracker.autorun (computation) =>
      return if @completed()
      return unless @activeConditions()
      return unless @completedConditions()
      
      @completed true
      @onCompleted()
  
    @_resetCompletedAutorun = Tracker.autorun (computation) =>
      return unless @completed()
      return unless @resetCompletedConditions()
  
      @completed false

  destroy: ->
    @_activeAutorun.stop()
    @_completedAutorun.stop()
    @_resetCompletedAutorun.stop()
    
  id: -> @constructor.id()

  message: -> @translate('message').text
  messageTranslation: -> @translation 'message'
  
  activeConditions: -> @constructor.activeConditions()
  completedConditions: -> @constructor.completedConditions()
  resetCompletedConditions: -> @constructor.resetCompletedConditions()
  priority: -> @constructor.priority()
  delayDuration: -> @constructor.delayDuration()
  activeDisplayState: -> @constructor.activeDisplayState()
  displaySide: -> @constructor.displaySide()
  
  onActivate: ->
    # Override to perform additional setup when the instruction activates.
    @resetDelay()
  
  onDeactivate: ->
    # Override to perform any cleanup when the instruction deactivates.
  
  onCompleted: ->
    # Override to do something when the instruction has completed.
  
  onDisplay: ->
    # Override to do something when the instruction starts displaying.
    
  onDisplayed: ->
    # Override to do something when the instruction is fully displayed.
  
  resetDelay: -> @delayTime @delayDuration()
  
  reduceDelayTime: (elapsedTime) ->
    @delayTime Math.max 0, @delayTime() - elapsedTime

  delayed: -> @delayTime() > 0
