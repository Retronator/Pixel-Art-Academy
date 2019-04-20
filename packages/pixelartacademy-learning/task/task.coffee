AB = Artificial.Babel
PAA = PixelArtAcademy

class PAA.Learning.Task
  @_taskClassesById = {}

  @PredecessorsCompleteType:
    All: 'All'
    Any: 'Any'

  @Icons:
    Task: 'Task'
    Drawing: 'Drawing'
    Reading: 'Reading'
    Video: 'Video'

  @getClassForId: (id) ->
    @_taskClassesById[id]

  # Id string for this task used to identify the task in code.
  @id: -> throw new AE.NotImplementedException "You must specify task's id."

  # The type that identifies the task class individual tasks inherit from.
  @type: null

  # The icon that represents the kind of work done in this task.
  @icon: @Icons.Task

  # Short description of the task's goal.
  @directive: -> throw new AE.NotImplementedException "You must specify the task directive."

  # Instructions how to complete this task.
  @instructions: -> throw new AE.NotImplementedException "You must specify the task instructions."

  # Override to list the interests this task increases.
  @interests: -> []

  # Override to specify interests required to attempt this task.
  @requiredInterests: -> []

  # Override to provide the classes of tasks leading to this task.
  @predecessors: -> []
  @predecessorsCompleteType: -> @PredecessorsCompleteType.All

  # Override to place the task in a different group. Tasks in the same group will be drawn
  # together as a linear progression. Lower numbers indicate earlier appearance within the goal.
  @groupNumber: -> 0

  @initialize: ->
    # Store task class by ID.
    @_taskClassesById[@id()] = @

    # On the server, create this avatar's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['directive', 'instructions']

  constructor: (@options = {}) ->
    # By default the task is related to the current character.
    @options.characterId ?= => LOI.characterId()

    # Subscribe to this goal's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace

    @type = @constructor.type

  destroy: ->
    @_translationSubscription.stop()

  id: -> @constructor.id()

  directive: -> AB.translate(@_translationSubscription, 'directive').text
  directiveTranslation: -> AB.translation @_translationSubscription, 'directive'

  instructions: -> AB.translate(@_translationSubscription, 'instructions').text
  instructionsTranslation: -> AB.translation @_translationSubscription, 'instructions'

  interests: -> @constructor.interests()
  requiredInterests: -> @constructor.requiredInterests()
  predecessors: -> @constructor.predecessors()
  groupNumber: -> @constructor.groupNumber()

  entry: ->
    return unless characterId = @options.characterId()

    # TODO: Add support for resetting goals/tasks
    
    PAA.Learning.Task.Entry.documents.findOne
      taskId: @id()
      'character._id': characterId

  completed: ->
    # We need an entry made by this character.
    @entry()

  active: (otherTasks) ->
    # We should only be determining active state for the current character.
    unless @options.characterId() is LOI.characterId()
      console.warn "Active task determination requested for another character."
      return

    # Predecessors need to be completed for the task to be active.
    predecessors = @predecessors()

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

    # TODO: Check that the character has all required interests.

    # Task is active until completed.
    not @completed()
