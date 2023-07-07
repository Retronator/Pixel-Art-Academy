PAA = PixelArtAcademy
Entry = PAA.PixelPad.Apps.Journal.JournalView.Entry
IL = Illustrapedia

class Entry.Object.Task extends Entry.Object
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Journal.JournalView.Entry.Object.Task'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'task'
    tag: 'p'
    class: 'pixelartacademy-pixelpad-apps-journal-journalview-entry-object-task'

  onCreated: ->
    super arguments...

    value = @value()
    taskClass = PAA.Learning.Task.getClassForId value.id
    
    unless taskClass
      console.warn "Unknown task with ID", value.id
      return

    @characterId = new ComputedField =>
      @quillComponent()?.entry()?.journal.character._id
    ,
      true
      
    goalClass = taskClass.goal()

    @goal = new goalClass
      characterId: @characterId
      
    @task = _.find @goal.tasks(), (task) => task instanceof taskClass

    @taskEntry = new ComputedField =>
      # Note: We must use reactive value here because it can change when setting the entry automatically below.
      return unless entryId = @value().entry?._id

      PAA.Learning.Task.Entry.documents.findOne entryId

    @taskComponent = new @constructor[taskClass.type()] @

    # If we don't have an entry yet, see if one exists and automatically set it.
    unless value.entry?._id
      # TODO: Handle resets of goals to only pick an entry after the reset date.
      @autorun (computation) =>
        return unless entry = @task.entry()

        # We found the entry, so update our value.
        value.entry = _id: entry._id
        @value value

  onDestroyed: ->
    super arguments...

    @goal?.destroy()
    @characterId?.stop()

  completed: ->
    # Task is completed if we have an entry. We use the value version to forgo loading.
    @value().entry?._id

  completedClass: ->
    'completed' if @completed()
    
  active: ->
    return if @readOnly()
    
    @task.active @goal.tasks()

  activeClass: ->
    'active' if @active()

  readOnlyClass: ->
    'read-only' if @readOnly()

  prerequisitesAll: ->
    @task.constructor.predecessorsCompleteType() is PAA.Learning.Task.PredecessorsCompleteType.All

  prerequisites: ->
    tasks = @goal.tasks()
    prerequisites = []

    # See if we only need one predecessor completed.
    anyCompleted = @task.constructor.predecessorsCompleteType() is PAA.Learning.Task.PredecessorsCompleteType.Any

    for predecessorClass in @task.predecessors()
      predecessor = _.find tasks, (task) => task instanceof predecessorClass

      if predecessor.completed()
        # We found a completed predecessor. If we only need to find one, there are no other prerequisites.
        return [] if anyCompleted

      else
        # Add this uncompleted task as a prerequisite.
        prerequisites.push predecessor

    prerequisites
