AB = Artificial.Babel
PAA = PixelArtAcademy

class PAA.Learning.Task
  @_taskClassesById = {}

  @getClassForId: (id) ->
    @_taskClassesById[id]

  # Id string for this task used to identify the task in code.
  @id: -> throw new AE.NotImplementedException "You must specify task's id."

  # Short description of the task's goal.
  @directive: -> throw new AE.NotImplementedException "You must specify the task directive."

  # Instructions how to complete this task.
  @instructions: -> throw new AE.NotImplementedException "You must specify the task instructions."

  # Override to list the interests this task increases.
  @interests: -> []

  @initialize: ->
    # Store task class by ID.
    @_taskClassesById[@id()] = @

    # On the server, create this avatar's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['directive', 'instructions']

  constructor: ->
    # Subscribe to this goal's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace

  destroy: ->
    @_translationSubscription.stop()

  id: -> @constructor.id()
  directive: -> AB.translate(@_translationSubscription, 'directive').text
  instructions: -> AB.translate(@_translationSubscription, 'instructions').text

  completed: ->
    return unless characterId = LOI.characterId()
    
    # Find a task entry made by this character.
    @constructor.Entry.documents.findOne
      taskType: @id()
      'character._id': characterId
