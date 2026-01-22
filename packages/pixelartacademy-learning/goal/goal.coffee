AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.Learning.Goal
  @_goalClassesById = {}
  @_goalClassesUpdatedDependency = new Tracker.Dependency

  @FinalTasksCompleteType:
    All: 'All'
    Any: 'Any'
    
  @getClassForId: (id) ->
    @_goalClassesUpdatedDependency.depend()
    @_goalClassesById[id]

  @removeClassForId: (id) ->
    delete @_goalClassesById[id]
    @_goalClassesUpdatedDependency.depend()

  @getClasses: ->
    @_goalClassesUpdatedDependency.depend()
    _.values @_goalClassesById

  # Id string for this goal used to identify the goal in code.
  @id: -> throw new AE.NotImplementedException "You must specify goal's id."

  # String to represent the goal in the UI. Note that we can't use
  # 'name' since it's an existing property holding the class name.
  @displayName: -> throw new AE.NotImplementedException "You must specify the goal name."
  
  # Chapter class that should oversee this goal.
  @chapter: -> throw new AE.NotImplementedException "You must provide the chapter class that activates this goal."

  # Override to provide task classes that are included in this goal.
  @tasks: -> []

  # Override to provide task classes that complete this goal.
  @finalTasks: -> []
  @finalTasksCompleteType: -> @FinalTasksCompleteType.Any
  @finalGroupNumber: -> 0

  @initialize: ->
    # Store goal class by ID.
    @_goalClassesById[@id()] = @
    @_goalClassesUpdatedDependency.changed()

    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create this goal's translated names.
        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName']

        # Initialize own interests.
        IL.Interest.initialize interest for interest in @ownRequiredInterests()

    # Reset interests lists so that they will get recalculated when accessed next.
    @_interests = null
    @_requiredInterests = null
    @_optionalInterests = null

  @ownRequiredInterests: ->
    # Override to provide any requirements directly required by the goal, not coming from the tasks.
    []

  @interests: ->
    return @_interests if @_interests
    @_determineInterests()
    @_interests

  @requiredInterests: ->
    return @_requiredInterests if @_requiredInterests
    @_determineInterests()
    @_requiredInterests

  @optionalInterests: ->
    return @_optionalInterests if @_optionalInterests
    @_determineInterests()
    @_optionalInterests

  @_determineInterests: ->
    # Create a list of interests increased by completing this goal's tasks.
    @_interests = []
    for task in @tasks()
      @_interests = _.union @_interests, task.interests()

    # Analyze required interests of tasks.
    @_requiredInterests = null
    @_optionalInterests = []

    # Go over all possible ways to reach the end.
    paths = @_findPathsToEnd()

    for path in paths
      # Find required interests in this path.
      pathRequiredInterests = []
      pathProvidedInterests = []

      for task in path
        pathRequiredInterests = _.union pathRequiredInterests, task.requiredInterests()
        pathProvidedInterests = _.union pathProvidedInterests, task.interests()

      # Self-provided interests don't need to be required.
      pathRequiredInterests = _.without pathRequiredInterests, pathProvidedInterests

      unless @_requiredInterests
        @_requiredInterests = pathRequiredInterests

      else
        # To find universal required interests, they need to intersect with the current ones.
        newRequiredInterests = _.intersection @_requiredInterests, pathRequiredInterests

        # Any interests that are not in the intersection, are optional.
        @_optionalInterests = _.union @_optionalInterests, _.difference @_requiredInterests, newRequiredInterests
        @_optionalInterests = _.union @_optionalInterests, _.difference pathRequiredInterests, newRequiredInterests

        @_requiredInterests = newRequiredInterests

    # Add goal's own required interests.
    @_requiredInterests = _.union @_requiredInterests, @ownRequiredInterests()

    # Make sure no interest is both required and optional.
    duplicateInterests = _.intersection @_requiredInterests, @_optionalInterests
    if duplicateInterests.length
      console.warn "Duplicate interests for goal", @id(), duplicateInterests, @_requiredInterests, @_optionalInterests

  @_findPathsToEnd: ->
    # To get to the end, we can come from any of the final tasks.
    finalTasks = @finalTasks()
    finalTaskPaths = (@_findPaths predecessor for predecessor in finalTasks)

    if @finalTasksCompleteType() is @FinalTasksCompleteType.All
      # We need to take one path from each of the final tasks, so we create all possible combinations.
      combinations = _.cartesianProduct finalTaskPaths...

      # Each combination is now an array of sub-paths, so we just concatenate all tasks found in these sub-paths.
      paths = (_.uniq _.flattenDeep combination for combination in combinations)

    else
      # We can take any of the paths from final tasks so simply merge them together.
      paths = _.flatten finalTaskPaths

    paths
    
  @_findPaths: (task) ->
    # To get to this task, we can come from any of the predecessors.
    predecessors = task.predecessors()

    # If there are no predecessors, this is the start of the path.
    unless predecessors.length
      pathStart = [task]
      return [pathStart]

    predecessorPaths = (@_findPaths predecessor for predecessor in predecessors)

    if task.predecessorsCompleteType() is PAA.Learning.Task.PredecessorsCompleteType.All
      # We need to take one path from each of the predecessors, so we create all possible combinations.
      combinations = _.cartesianProduct predecessorPaths...

      # Each combination is now an array of sub-paths, so we just concatenate all tasks found in these sub-paths.
      paths = (_.uniq _.flattenDeep combination for combination in combinations)

    else
      # We can take any of the paths from predecessors so simply merge them together.
      paths = _.flatten predecessorPaths

    # Add current task to the end of all paths.
    path.push task for path in paths

    paths
    
  @isInterestProvidedFromIndividuallyCompletedFinalTask: (interest) ->
    switch @finalTasksCompleteType()
      when @FinalTasksCompleteType.All
        # We can get this interest from completing the goal only if there's only one final task that provides it.
        finalTasks = @finalTasks()
        return false unless finalTasks.length is 1
        interest in finalTasks[0].interests()
        
      when @FinalTasksCompleteType.Any
        # We can get this interest from completing the goal if any final task provides it.
        for finalTask in @finalTasks()
          return true if interest in finalTask.interests()
          
        false
      
  @doesCompletingAnyFinalTaskCompleteTheGoal: ->
    @finalTasksCompleteType() is @FinalTasksCompleteType.Any or @finalTasks().length is 1

  @getAdventureInstanceForId: (goalId) ->
    return unless LOI.adventureInitialized()
    
    for episode in LOI.adventure.episodes()
      for chapter in episode.chapters
        for goal in chapter.goals
          return goal if goal.id() is goalId

    # If the goal is not part of the storyline, it might be in the Study Guide.
    if studyGuideGlobal = _.find LOI.adventure.globals(), (global) => global instanceof PAA.StudyGuide.Global
      for studyGuideGoalId, goal of studyGuideGlobal.goals()
        return goal if studyGuideGoalId is goalId

    console.warn "Unknown goal requested.", goalId
    null

  @getAdventureInstance: -> @getAdventureInstanceForId @id()
  
  @completed: -> @getAdventureInstance().completed()
  @allCompleted: -> @getAdventureInstance().allCompleted()
  @active: -> @getAdventureInstance().active()
  @available: -> @getAdventureInstance().available()
  @activeAndAvailable: -> @getAdventureInstance().activeAndAvailable()
  @activeOrCompleted: -> @getAdventureInstance().activeOrCompleted()
  @activeAndAvailableOrCompleted: -> @getAdventureInstance().activeAndAvailableOrCompleted()
  
  @reset: -> @getAdventureInstance().reset()
  
  constructor: (@options = {}) ->
    # By default the task is related to the current profile.
    @options.profileId ?= => LOI.adventure.profileId()
    @options.goal = @

    @_tasks = []
    @_finalTasks = []

    finalTaskClasses = @constructor.finalTasks()

    for taskClass in @constructor.tasks()
      task = new taskClass @options
      @_tasks.push task
      @_finalTasks.push task if taskClass in finalTaskClasses

    # Subscribe to this goal's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace

  destroy: ->
    @_translationSubscription.stop()

    task.destroy() for task in @_tasks

  id: -> @constructor.id()

  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'
  
  tasks: -> @_tasks
  finalTasks: -> @_finalTasks
  initialTasks: -> _.filter @_tasks, (task) => not task.predecessors().length
  completableTasks: -> _.filter @_tasks, (task) => task.completable()

  interests: -> @constructor.interests()
  requiredInterests: -> @constructor.requiredInterests()
  optionalInterests: -> @constructor.optionalInterests()
  finalGroupNumber: -> @constructor.finalGroupNumber()

  # The goal is completed when at least one of the final tasks has been reached.
  completed: ->
    _.some (task.completed() for task in @finalTasks())
    
  # The goal is fully completed when all of the tasks are completed.
  allCompleted: ->
    _.every (task.completed() for task in @tasks())

  # A goal is active when it has been added to the study plan and not marked complete.
  active: -> PAA.PixelPad.Apps.StudyPlan.hasActiveGoal @
  
  # A goal is available when one of its initial tasks is available or completed.
  available: -> _.some (task.availableOrCompleted() for task in @initialTasks())

  activeAndAvailable: -> @active() and @available()
  activeOrCompleted: -> @active() or @completed()
  activeAndAvailableOrCompleted: -> @activeAndAvailable() or @completed()

  reset: ->
    task.reset() for task in @_tasks
