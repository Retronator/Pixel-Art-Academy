AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.StudyGuide.Pages.Admin.Activities.Activity extends AM.Component
  @id: -> 'PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity'
  @register @id()

  onCreated: ->
    super arguments...

    @renaming = new ReactiveField false

    @goalTranslationHandle = new ComputedField =>
      activity = @data()
      translationNamespace = activity.goalId
      AB.subscribeNamespace translationNamespace

  onDestroyed: ->
    @_renamingStopAutorun?.stop()

  taskTypes: ->
    # Automatic tasks are not allowed in the journal.
    _.without PAA.Learning.Task.getTypes(), 'Automatic'

  goalDisplayNameTranslation: ->
    return if @renaming()
    AB.translation @goalTranslationHandle(), 'displayName'

  events: ->
    super(arguments...).concat
      'click .rename-goal-button': @onClickRenameGoalButton
      'click .remove-activity-button': @onClickRemoveActivityButton
      'click .add-task-button': @onClickAddTaskButton

  onClickRenameGoalButton: (event) ->
    activity = @data()

    return unless newGoalId = prompt "Rename goal to", activity.goalId
    return if activity.goalId is newGoalId

    @_startRenaming activity.goalId
    PAA.StudyGuide.Activity.renameGoalId activity._id, newGoalId

  _startRenaming: (oldGoalId) ->
    @renaming true

    # Wait for new document to come back to allow editing again.
    @_renamingStopAutorun = Tracker.autorun (computation) =>
      activity = @data()
      return if activity.goalId is oldGoalId

      @renaming false
      computation.stop()

  onClickRemoveActivityButton: (event) ->
    activity = @data()
    return unless confirm "Remove activity #{activity.goalId}?"

    @_startRenaming activity.goalId
    PAA.StudyGuide.Activity.remove activity._id

  onClickAddTaskButton: ->
    taskSuffix = @$('.new-task-id').val()

    activity = @data()
    goalPrefix = activity.goalId

    taskId = "#{goalPrefix}.#{taskSuffix}"

    taskType = @$('.new-task-type').val()

    PAA.StudyGuide.Activity.insertTask activity._id, taskId, taskType, (error) =>
      return console.error error if error

    @$('.new-task-id').val('')

  class @FinalGroupNumber extends AM.DataInputComponent
    @register 'PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.FinalGroupNumber'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Number

    placeholder: -> 0

    load: ->
      activity = @data()
      activity.finalGroupNumber

    save: (value) ->
      activity = @data()
      PAA.StudyGuide.Activity.update activity._id, finalGroupNumber: value

  class @StringList extends AM.Component
    template: -> 'PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.StringList'

    constructor: ->
      super arguments...

      @newItemName = new ReactiveField ''

    items: ->
      activity = @data()
      activity[@fieldName]

    save: (updatedFields) ->
      activity = @data()
      PAA.StudyGuide.Activity.update activity._id, updatedFields

    setNewItemName: (newItemName) ->
      @$('.new-item-name').val newItemName
      @newItemName newItemName

    events: ->
      super(arguments...).concat
        'input .new-item-name': @onInputNewItemName
        'click .add-item-button': @onClickAddItemButton
        'click .remove-item-button': @onClickRemoveItemButton
        'click .autocomplete-items .item': @onClickAutocompleteItemsItem

    onInputNewItemName: (event) ->
      newItemName = @$(event.target).val()
      @newItemName newItemName

    onClickAddItemButton: (event) ->
      newItems = _.union @items(), [@newItemName()]
      @save "#{@fieldName}": newItems

      @setNewItemName ''

    onClickRemoveItemButton: (event) ->
      item = @currentData()
      newItems = _.without @items(), item
      @save "#{@fieldName}": newItems

    onClickAutocompleteItemsItem: (event) ->
      item = @currentData()
      @setNewItemName item

  class @TasksList extends @StringList
    possibleItems: ->
      activity = @data()
      return [] unless activity.tasks

      task.id for task in activity.tasks

  class @FinalTasks extends @TasksList
    @register "PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.FinalTasks"

    constructor: ->
      super arguments...

      @fieldName = 'finalTasks'

  class @InterestsList extends @StringList
    possibleItems: ->
      searchTerm = @newItemName()
      return unless searchTerm.length

      IL.Interest.forSearchTerm.subscribe searchTerm
      interest.name.translate().text for interest in IL.Interest.forSearchTerm.query(searchTerm).fetch()

  class @RequiredInterests extends @InterestsList
    @register "PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.RequiredInterests"

    constructor: ->
      super arguments...

      @fieldName = 'requiredInterests'
