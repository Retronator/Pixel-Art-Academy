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

  @priority: -> 0
  
  @delayDuration: -> 0

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
  
  constructor: ->
    super arguments...
  
    @delayTime = new ReactiveField 0
  
    @_wasActive = false
  
    @_activeAutorun = Tracker.autorun (computation) =>
      active = @activeConditions()
      
      @onActivate?() if active and not @_wasActive
      @onDeactivate?() if @_wasActive and not active
      
      @_wasActive = active
      
  destroy: ->
    super arguments...
  
    @_activeAutorun.stop()

  id: -> @constructor.id()

  message: -> @translate('message').text
  messageTranslation: -> @translation 'message'
  
  activeConditions: -> @constructor.activeConditions()

  priority: -> @constructor.priority()
  
  onActivate: ->
    @resetDelay()
  
  onDeactivate: -> # Override to perform any cleanup when the instruction deactivates.
  
  resetDelay: -> @delayTime @constructor.delayDuration()

  reduceDelayTime: (elapsedTime) ->
    @delayTime Math.max 0, @delayTime() - elapsedTime

  delayed: -> @delayTime() > 0
