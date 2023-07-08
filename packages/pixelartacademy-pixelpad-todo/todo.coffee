AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Systems.ToDo extends PAA.PixelPad.System
  @id: -> 'PixelArtAcademy.PixelPad.Systems.ToDo'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "To-do"
  @description: ->
    "
      The task-tracking information system.
    "

  @initialize()
  
  onCreated: ->
    super arguments...
    
    @selectedTask = new ReactiveField true
  
  taskSelectedClass: ->
    'task-selected' if @selectedTask()
    
  events: ->
    super(arguments...).concat
      'click .task': @onClickTask
      'click .back-button': @onClickBackButton
    
  onClickTask: (event) ->
    @selectedTask true
  
  onClickBackButton: (event) ->
    @selectedTask null
