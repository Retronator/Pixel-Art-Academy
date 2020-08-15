AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.Learning.Goal
  @_goalClassesById = {}
  @_goalClassesUpdatedDependency = new Tracker.Dependency

  @getClassForId: (id) ->
    @_goalClassesUpdatedDependency.depend()
    @_goalClassesById[id]
    
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
  @finalGroupNumber: -> 0

  @initialize: ->
    # Store goal class by ID.
    @_goalClassesById[@id()] = @
    @_goalClassesUpdatedDependency.changed()

    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create this avatar's translated names.
        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName']

        # Initialize own interests.
        IL.Interest.initialize interest for interest in @ownRequiredInterests()

    # Create a list of interests increased by completing this goal's tasks.
    @_interests = []
    for task in @tasks()
      @_interests = _.union @_interests, task.interests()

    # Create a list of interests required before attempting this goal and its tasks.
    @_requiredInterests = @ownRequiredInterests()
    for task in @tasks()
      @_requiredInterests = _.union @_requiredInterests, task.requiredInterests()

  @ownRequiredInterests: ->
    # Override to provide any requirements directly required by the goal, not coming from the tasks.
    []

  @interests: -> @_interests
  @requiredInterests: -> @_requiredInterests

  constructor: (@options = {}) ->
    # By default the task is related to the current character.
    @options.characterId ?= => LOI.characterId()
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

  interests: -> @constructor.interests()
  requiredInterests: -> @constructor.requiredInterests()
  finalGroupNumber: -> @constructor.finalGroupNumber()

  # The goal is completed when at least one of the final tasks has been reached.
  completed: ->
    _.some _.map @finalTasks(), (task) -> task.completed()
