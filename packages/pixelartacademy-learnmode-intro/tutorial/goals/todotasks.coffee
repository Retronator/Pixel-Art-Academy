LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.ToDoTasks extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.ToDoTasks'

  @displayName: -> "To-do tasks"

  @chapter: -> LM.Intro.Tutorial

  Goal = @
  
  class @OpenInstructions extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.ToDoTasks.OpenInstructions'
    @goal: -> Goal

    @directive: -> "Click here to read task instructions"

    @instructions: -> """
      This notepad will keep track of your current tasks.
      You can always click on a task to learn how to complete it.

      Click on the arrow to get back to the tasks.
    """
    
    @interests: -> ['to-do tasks']
    
    @studyPlanBuilding: -> 'SimCityResidential1'
  
    @initialize()
    
    constructor: ->
      super arguments...
      
      @_instructionsWereOpened = false
      @_instructionsWereOpenedAndClosed = new ReactiveField false
      
      @_instructionsAutorun = Tracker.autorun (computation) =>
        return unless LOI.adventure.ready()
        return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
        return unless toDoSystem = _.find pixelPad.os.currentSystems(), (system) => system instanceof PAA.PixelPad.Systems.ToDo
        return unless toDoSystem.isCreated()
        
        selectedTask = toDoSystem.selectedTask()
        
        # Wait for instructions to be opened.
        @_instructionsWereOpened = true if selectedTask
        
        # Wait for instructions to close after they've been opened.
        if @_instructionsWereOpened and not selectedTask
          @_instructionsWereOpenedAndClosed true
          computation.stop()
        
    destroy: ->
      super arguments...
      
      @_instructionsAutorun.stop()

    completedConditions: ->
      @_instructionsWereOpenedAndClosed()
    
    activeNotificationId: -> @constructor.ActiveNotification.id()
    
    Task = @
    
    class @ActiveNotification extends PAA.PixelPad.Systems.Notifications.Notification
      @id: -> "#{Task.id()}.ActiveNotification"
      
      @message: -> """
        Click on the notebook below to see your to-do tasks.
        
        And click on me anytime to hear my thoughts!
      """
      
      @priority: -> 1
      
      @initialize()
      
  @tasks: -> [
    @OpenInstructions
  ]

  @finalTasks: -> [
    @OpenInstructions
  ]

  @initialize()
