AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.StudyGuide.Pages.Admin.Activities.Activity.Task extends AM.Component
  @id: -> 'PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.Task'
  @register @id()

  onCreated: ->
    super arguments...

    @renaming = new ReactiveField false

    @activityComponent = @ancestorComponentOfType PAA.StudyGuide.Pages.Admin.Activities.Activity

    @taskTranslationHandle = new ComputedField =>
      task = @data()
      translationNamespace = task.id
      AB.subscribeNamespace translationNamespace

  onDestroyed: ->
    super arguments...

    @_renamingStopAutorun?.stop()

  taskDirectiveTranslation: ->
    return if @renaming() or @activityComponent.renaming()
    AB.translation @taskTranslationHandle(), 'directive'

  taskInstructionsTranslation: ->
    return if @renaming() or @activityComponent.renaming()
    AB.translation @taskTranslationHandle(), 'instructions'

  taskInstructionsTranslationInputOptions: ->
    type: AB.Components.Translatable.Types.TextArea

  events: ->
    super(arguments...).concat
      'click .rename-task-button': @onClickRenameTaskButton
      'click .remove-task-button': @onClickRemoveTaskButton

  onClickRenameTaskButton: (event) ->
    task = @data()
    return unless newTaskId = prompt "Rename task to", task.id
    return if task.id is newTaskId

    @_startRenaming task.id
    activity = @activityComponent.data()
    PAA.StudyGuide.Activity.renameTaskId activity._id, task.id, newTaskId

  _startRenaming: (oldTaskId) ->
    @renaming true

    # Wait for new document to come back to allow editing again.
    @_renamingStopAutorun = Tracker.autorun (computation) =>
      task = @data()
      return if task.id is oldTaskId

      @renaming false
      computation.stop()

  onClickRemoveTaskButton: (event) ->
    task = @data()
    return unless confirm "Remove task #{task.id}?"

    @_startRenaming task.id
    activity = @activityComponent.data()
    PAA.StudyGuide.Activity.removeTask activity._id, task.id

  class @Type extends AM.DataInputComponent
    @register 'PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.Task.Type'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super arguments...

      @activityComponent = @ancestorComponentOfType PAA.StudyGuide.Pages.Admin.Activities.Activity

    options: ->
      for type in _.without PAA.Learning.Task.getTypes(), PAA.Learning.Task.Automatic.type()
        name: type
        value: type

    load: ->
      task = @data()
      task.type

    save: (value) ->
      task = @data()
      activity = @activityComponent.data()
      PAA.StudyGuide.Activity.changeTaskType activity._id, task.id, value

  class @StringList extends PAA.StudyGuide.Pages.Admin.Activities.Activity.StringList
    onCreated: ->
      super arguments...

      @activityComponent = @ancestorComponentOfType PAA.StudyGuide.Pages.Admin.Activities.Activity

    items: ->
      task = @data()
      task[@fieldName]

    save: (updatedFields) ->
      task = @data()
      activity = @activityComponent.data()
      PAA.StudyGuide.Activity.updateTask activity._id, task.id, updatedFields

  class @Property extends AM.DataInputComponent
    onCreated: ->
      super arguments...

      @activityComponent = @ancestorComponentOfType PAA.StudyGuide.Pages.Admin.Activities.Activity

    load: ->
      task = @data()
      task[@fieldName]

    save: (value) ->
      task = @data()
      activity = @activityComponent.data()
      PAA.StudyGuide.Activity.updateTask activity._id, task.id, "#{@fieldName}": value

  class @Icon extends @Property
    @register 'PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.Task.Icon'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select
      @fieldName = 'icon'

    load: ->
      super(arguments...) or PAA.Learning.Task.icon()

    options: ->
      for icon of PAA.Learning.Task.Icons
        name: icon
        value: icon

  class @InterestsList extends @StringList
    possibleItems: ->
      searchTerm = @newItemName()
      return unless searchTerm.length

      IL.Interest.forSearchTerm.subscribe searchTerm
      interest.name.translate().text for interest in IL.Interest.forSearchTerm.query(searchTerm).fetch()

  class @Interests extends @InterestsList
    @register "PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.Task.Interests"

    constructor: ->
      super arguments...

      @fieldName = 'interests'

  class @RequiredInterests extends @InterestsList
    @register "PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.Task.RequiredInterests"

    constructor: ->
      super arguments...

      @fieldName = 'requiredInterests'

  class @TasksList extends @StringList
    possibleItems: ->
      activity = @activityComponent.data()
      return [] unless activity.tasks

      task.id for task in activity.tasks

  class @Predecessors extends @TasksList
    @register "PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.Task.Predecessors"

    constructor: ->
      super arguments...

      @fieldName = 'predecessors'

  class @PredecessorsCompleteType extends @Property
    @register 'PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.Task.PredecessorsCompleteType'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select
      @fieldName = 'predecessorsCompleteType'

    load: ->
      super(arguments...) or PAA.Learning.Task.predecessorsCompleteType()

    options: ->
      for type of PAA.Learning.Task.PredecessorsCompleteType
        name: type
        value: type

  class @GroupNumber extends @Property
    @register 'PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.Task.GroupNumber'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Number
      @fieldName = 'groupNumber'

    placeholder: -> 0
