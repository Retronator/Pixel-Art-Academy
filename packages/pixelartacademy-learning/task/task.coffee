AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.Learning.Task
  @_taskClassesById = {}
  @_taskClassesUpdatedDependency = new Tracker.Dependency

  @PredecessorsCompleteType:
    All: 'All'
    Any: 'Any'

  @Icons:
    Task: 'Task'
    Drawing: 'Drawing'
    Reading: 'Reading'
    Video: 'Video'

  @getClassForId: (id) ->
    @_taskClassesUpdatedDependency.depend()
    @_taskClassesById[id]

  @removeClassForId: (id) ->
    delete @_taskClassesById[id]
    @_taskClassesUpdatedDependency.depend()

  @getTypes: ->
    property for property, value of @ when value.prototype instanceof @

  # Id string for this task used to identify the task in code.
  @id: -> throw new AE.NotImplementedException "You must specify task's id."

  # The type that identifies the task class individual tasks inherit from.
  @type: -> null

  # The icon that represents the kind of work done in this task.
  @icon: -> @Icons.Task
  
  # Override if this task is not yet available.
  @completable: -> true

  # Short description of the task's goal.
  @directive: -> throw new AE.NotImplementedException "You must specify the task directive."

  # Instructions how to complete this task.
  @instructions: -> throw new AE.NotImplementedException "You must specify the task instructions."

  # Override to provide alternative texts to show in the Study Plan app.
  @studyPlanDirective: -> null
  @studyPlanInstructions: -> null

  # Override to list the interests this task increases.
  @interests: -> []

  # Override to specify interests required to attempt this task.
  @requiredInterests: -> []

  # Override to provide the classes of tasks leading to this task.
  @predecessors: -> []
  @predecessorsCompleteType: -> @PredecessorsCompleteType.All

  # Override to specify which building image to use in the Study Plan.
  @studyPlanBuilding: -> ''
  
  # Override to place the task in a different group. Tasks in the same group will be drawn
  # together as a linear progression. Lower numbers indicate earlier appearance within the goal.
  @groupNumber: -> 0

  # Override to force the task to a specific level.
  @level: -> null
  
  @onActive: -> # Override to perform an action when the task has evaluated to active.
  
  @onActiveDisplayed: -> # Override to perform an action when the task has been displayed as active to the player.
  
  @onCompletedDisplayed: -> # Override to perform an action when the task has been displayed as completed to the player.

  @initialize: ->
    # Store task class by ID.
    @_taskClassesById[@id()] = @
    @_taskClassesUpdatedDependency.changed()

    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create this task's translated names.
        translationNamespace = @id()
        for property in ['directive', 'instructions', 'studyPlanDirective', 'studyPlanInstructions']
          continue unless text = @[property]()
          AB.createTranslation translationNamespace, property, text

        # Initialize interests.
        IL.Interest.initialize interest for interest in _.union @interests(), @requiredInterests()

  @getAdventureInstanceForId: (taskId) ->
    return unless LOI.adventureInitialized()
    
    for episode in LOI.adventure.episodes()
      for chapter in episode.chapters
        for task in chapter.tasks
          return task if task.id() is taskId

    # If task is not part of the storyline, it might be in the Study Guide.
    if studyGuideGlobal = _.find LOI.adventure.globals(), (global) => global instanceof PAA.StudyGuide.Global
      for task in studyGuideGlobal.tasks()
        return task if task.id() is taskId

    console.warn "Unknown task requested.", taskId
    null
  
  @getAdventureInstance: -> @getAdventureInstanceForId @id()

  @completed: -> @getAdventureInstance().completed()

  @reset: -> @getAdventureInstance().reset()

  constructor: (@options = {}) ->
    @goal = @options.goal

    # By default the task is related to the current profile.
    @options.profileId ?= => LOI.adventure.profileId()

    # Subscribe to this goal's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace

  destroy: ->
    @_translationSubscription.stop()

  id: -> @constructor.id()
  type: -> @constructor.type()
  
  completable: -> @constructor.completable()

  directive: -> AB.translate(@_translationSubscription, 'directive').text
  directiveTranslation: -> AB.translation @_translationSubscription, 'directive'

  instructions: -> AB.translate(@_translationSubscription, 'instructions').text
  instructionsTranslation: -> AB.translation @_translationSubscription, 'instructions'

  studyPlanDirective: ->
    translation = AB.translate @_translationSubscription, 'studyPlanDirective'
    return translation.text if translation.language
    @directive()
    
  studyPlanDirectiveTranslation: -> AB.existingTranslation(@_translationSubscription, 'studyPlanDirective') or @directiveTranslation()
  
  studyPlanInstructions: -> AB.translate(@_translationSubscription, 'studyPlanInstructions').text
  studyPlanInstructionsTranslation: -> AB.existingTranslation(@_translationSubscription, 'studyPlanInstructions') or @instructionsTranslation()
  
  interests: -> @constructor.interests()
  requiredInterests: -> @constructor.requiredInterests()
  predecessors: -> @constructor.predecessors()
  studyPlanBuilding: -> @constructor.studyPlanBuilding()
  groupNumber: -> @constructor.groupNumber()
  level: -> @constructor.level()
  
  onActive: -> @constructor.onActive()
  onActiveDisplayed: -> @constructor.onActiveDisplayed()
  onCompletedDisplayed: -> @constructor.onCompletedDisplayed()

  entry: ->
    PAA.Learning.Task.Entry.documents.findOne
      taskId: @id()
      profileId: @options.profileId()

  completed: ->
    # We need an entry made by this profile.
    @entry()

  # Task is available when all prerequisites are completed and until it is completed.
  available: ->
    # We should only be determining active state for the current profile.
    unless @options.profileId() is LOI.adventure.profileId()
      console.warn "Active task determination requested for another profile."
      return
      
    # Filter uncompletable tasks.
    return unless @constructor.completable()

    # Task is not available after it's completed.
    return if @completed()

    # Predecessors need to be completed for the task to be active.
    predecessors = @predecessors()
    otherTasks = @goal.tasks()

    if predecessors.length
      # Count how many predecessors are completed.
      predecessorsCompletedCount = 0

      for predecessorClass in predecessors
        continue unless task = _.find otherTasks, (task) => task instanceof predecessorClass
        predecessorsCompletedCount++ if task.completed()

      switch @constructor.predecessorsCompleteType()
        when @constructor.PredecessorsCompleteType.All
          return false unless predecessorsCompletedCount is predecessors.length

        when @constructor.PredecessorsCompleteType.Any
          return false if predecessorsCompletedCount is 0

    # Check that the profile has all required interests.
    return false unless @hasRequiredInterests()

    # All requirements to be active have been met.
    true

  # Task is active when it is available and its goal is active.
  active: ->
    @available() and @goal.active()
    
  hasRequiredInterests: ->
    requiredInterests = @requiredInterests()
    _.intersection(requiredInterests, LOI.adventure.currentInterests()).length is requiredInterests.length
    
  reset: ->
    PAA.Learning.Task.Entry.documents.remove
      taskId: @id()
      profileId: @options.profileId()
