PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry
IL = Illustrapedia

class Entry.Object.Task extends Entry.Object
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Object.Task'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'task'
    tag: 'p'
    class: 'pixelartacademy-pixelboy-apps-journal-journalview-entry-object-task'

  onCreated: ->
    super

    value = @value()
    taskClass = PAA.Learning.Task.getClassForId value.id

    @task = new taskClass

    if taskClass.type
      @taskComponent = new @constructor[taskClass.type]

  taskComponentClass: ->
    value = @value()
    taskClass = PAA.Learning.Task.getClassForId value.id

    @constructor[taskClass.type] or null

  interestDocument: ->
    interest = @currentData()
    IL.Interest.find interest
