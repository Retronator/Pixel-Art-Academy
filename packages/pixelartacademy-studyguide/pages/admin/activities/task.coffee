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

    @activityComponent = @ancestorComponentOfType PAA.StudyGuide.Pages.Admin.Activities.Activity

    @taskTranslationHandle = new ComputedField =>
      task = @data()
      translationNamespace = task.id
      AB.subscribeNamespace translationNamespace

  taskDirectiveTranslation: -> AB.translation @taskTranslationHandle(), 'directive'
  taskInstructionsTranslation: ->
    AB.translation @taskTranslationHandle(), 'instructions'

  taskInstructionsTranslationInputOptions: ->
    type: AB.Components.Translatable.Types.TextArea

  events: ->
    super(arguments...).concat
      'click .remove-task-button': @onClickRemoveTaskButton

  onClickRemoveTaskButton: (event) ->
    task = @data()
    activity = @activityComponent.data()
    PAA.StudyGuide.Activity.removeTask activity._id, task.id

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
