AB = Artificial.Babel
PAA = PixelArtAcademy

class PAA.Learning.Goal
  @_goalClassesById = {}

  @getClassForId: (id) ->
    @_goalClassesById[id]
    
  @getClasses: ->
    _.values @_goalClassesById

  # Id string for this goal used to identify the goal in code.
  @id: -> throw new AE.NotImplementedException "You must specify goal's id."

  # String to represent the goal in the UI. Note that we can't use
  # 'name' since it's an existing property holding the class name.
  @displayName: -> throw new AE.NotImplementedException "You must specify the goal name."

  # Override to provide task classes that are included in this goal.
  @tasks: -> []

  @initialize: ->
    # Store goal class by ID.
    @_goalClassesById[@id()] = @

    # On the server, create this avatar's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName']

    # Create a list of interests increased by completing this goal's tasks.
    @interests = []
    for task in @tasks()
      @interests = _.union @interests, task.interests()

  constructor: ->
    @tasks = []

    for taskClass in @constructor.tasks()
      @tasks.push new taskClass

    # Subscribe to this goal's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace

    @interests = @constructor.interests

  destroy: ->
    @_translationSubscription.stop()

    task.destroy() for task in @tasks

  id: -> @constructor.id()
  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'

  # Override to define when the goal has been reached.
  completed: -> false

  # Helper method that tells if all goal's tasks are completed.
  allTasksCompleted: ->
    _.every _.map @tasks, (task) -> task.completed()
